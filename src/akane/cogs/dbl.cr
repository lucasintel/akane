module Akane
  module BotList
    include Cog

    BASE = "https://discordbots.org/api/widget"

    @[Command(
      name: "dbl",
      description: "Display bot stats",
      category: "Meta",
      usage: "(mention)",
      hidden: true
    )]
    def dbl(client, payload, args)
      return "No mention found." unless bot = Discord::Mention.parse(args).first?

      case bot
      when Discord::Mention::User
        id = bot.id
      else
        return "Failed to parse mention."
      end

      Discord::Embed.new(
        author: Discord::EmbedAuthor.new(
          name: "Dicord Bots",
          url: "https://discordbots.org/bot/#{id}"
        ),
        colour: 3553598,
        image: Discord::EmbedImage.new(url: "#{BASE}/#{id}.png")
      )
    end

    @[SubCommand("dbl", "--vote")]
    def vote(client, payload, args)
      ":hearts: https://discordbots.org/bot/#{ENV["CLIENT_ID"]}/vote"
    end
  end
end
