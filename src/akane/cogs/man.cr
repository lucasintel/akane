module Akane
  module Man
    include Cog

    @[Command(
      name: "man",
      description: "Simplified and community-driven man pages.",
      usage: "(name)"
    )]
    def man(client, payload, args)
      res = DB.query_one?(DB.find_man, args.first, as: {String, String})
      return unless res

      description, url = res

      embed = Discord::Embed.new(
        title: args.first,
        description: String.build do |s|
          s << description << "\n"
          s << url
        end
      )

      client.create_message(payload.channel_id, "", embed)
    end
  end
end
