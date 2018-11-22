module Akane
  module Help
    include Cog

    private def cmd_help(args)
      return unless cmd = Akane::Command[args.first]

      Discord::Embed.new(
        title: "#{cmd.name} #{cmd.usage}",
        description: cmd.description,
        colour: 6844039_u32,
        footer: Discord::EmbedFooter.new(
          text: "The number of args must match the range #{cmd.args.to_s}."
        )
      )
    end

    @[Command(
      name: "help",
      description: "Probably the most useful command",
      usage: "(cmd)?"
    )]
    def help(client, payload, args)
      if args.any?
        return client.create_message(payload.channel_id, "", cmd_help(args))
      end

      commands = Akane::Command.list.each_value.map(&.name).join(", ")

      embed = Discord::Embed.new(
        title: "Help",
        description: commands,
        colour: 6844039_u32,
        footer: Discord::EmbedFooter.new(
          text: "For more info on a command, use \"!a help (cmd)\"."
        )
      )

      client.create_message(payload.channel_id, "", embed)
    end
  end
end
