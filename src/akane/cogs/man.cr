require "myhtml"

module Akane
  module Man
    include Cog

    struct Tlcr
      ::DB.mapping({
          name: String,
          description: String,
          url: String
        },
        strict: false
      )

      def to_s
        String.build do |s|
          s << description << "\n"
          s << url
        end
      end
    end

    @[Command(
      name: "man",
      description: "Simplified and community-driven man pages.",
      usage: "(name)"
    )]
    def man(client, payload, args)
      res = DB::PG.connection(&.query(DB.find_man, args.first))
      return unless res

      command = Tlcr.from_rs(res)

      embed = Discord::Embed.new(
        title: command[0].name,
        description: command[0].to_s,
        colour: 1118482_u32
      )

      client.create_message(payload.channel_id, "", embed)
    end
  end
end
