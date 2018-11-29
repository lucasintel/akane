module Akane
  module Xkcd
    include Cog

    struct Comic
      JSON.mapping(
        num: UInt32,
        title: String,
        img: String,
        day: String,
        month: String,
        year: String
      )

      def published_at
        "#{day}/#{month}/#{year}"
      end
    end

    @[Command(
      name: "xkcd",
      description: "Get latest (or specific) xkcd comic",
      usage: "(id)?"
    )]
    def xkcd(client, payload, args)
      res = HTTP::Client.get("https://xkcd.com/#{args}/info.0.json")
      return "Request failed." unless res.success?

      comic = Comic.from_json(res.body)

      Discord::Embed.new(
        title: "#{comic.title} (##{comic.num})",
        colour: 9873608_u32,
        image: Discord::EmbedImage.new(url: comic.img),
        footer: Discord::EmbedFooter.new(text: comic.published_at)
      )
    end
  end
end
