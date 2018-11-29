require "myhtml"

module Akane
  module Man
    include Cog

    struct Man
      ::DB.mapping(
        name: String,
        description: String,
        url: String
      )

      def to_s
        String.build do |s|
          s << description << "\n"
          s << url
        end
      end

      def self.find(name)
        DB::PG.connection do |pg|
          from_rs(pg.query(DB.find_man, name))
        end
      end
    end

    @[Command(
      name: "man",
      description: "Simplified and community-driven man pages.",
      missing_args: "What manual page do you want?",
      usage: "(name)"
    )]
    def man(client, payload, args)
      return "Not found" unless command = Man.find(args).first?

      Discord::Embed.new(
        title: command.name,
        description: command.to_s,
        colour: 6844039_u32
      )
    end
  end
end
