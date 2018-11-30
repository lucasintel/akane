require "myhtml"

module Akane
  module Boatos
    include Cog

    struct Article
      getter title : String
      getter url : String
      getter image : String?
      getter description : String
      getter published_at : String

      def initialize(@title, @image, @description, @url, @published_at)
      end

      def timestamp : Time
        @timestamp ||= Time.parse(published_at, "%d/%m/%Y", Time::Location.local)
      end
    end

    @[Command(
      name: "boato",
      description: "Busque por boatos",
      usage: "...",
      hidden: true
    )]
    def boato(client, payload, args)
      res = HTTP::Client.get("https://www.boatos.org/?s=#{args.tr(" ", "+")}")
      return "Request failed." unless res.success?

      articles = Myhtml::Parser.new(res.body).nodes(:article)
      return "Failed to parse page." unless articles

      if articles.size > 1
        links = String.build do |s|
          articles.each do |article|
            link = article.css(".entry-title a").first.inner_text
            url = article.css(".entry-title a").first.attribute_by("href")

            s << "- [" << link.gsub(" #boato", "") << "](" << url << ")\n"
          end
        end

        Discord::Embed.new(
          author: Discord::EmbedAuthor.new(
            name: "Boatos.org",
            url: "https://www.boatos.org/"
          ),
          description: links.lines.first(5).join("\n"),
          colour: 3553598_u32,
          timestamp: Time.utc_now
        )
      else
        article = articles.first

        boato = Article.new(
          title: article.css(".entry-title a").first.inner_text.gsub(" #boato", ""),
          url: article.css(".entry-title a").first.attribute_by("href").as(String),
          image: article.css(".featured-image img").first.try(&.attribute_by("src")),
          description: article.css(".entry-content p").first.inner_text,
          published_at: article.css(".entry-date").first.inner_text
        )

        Discord::Embed.new(
          author: Discord::EmbedAuthor.new(
            name: "Boatos.org",
            url: "https://www.boatos.org/"
          ),
          title: boato.title,
          url: boato.url,
          image: Discord::EmbedImage.new(url: boato.image.as(String)),
          description: boato.description,
          colour: 6844039_u32,
          timestamp: boato.timestamp
        )
      end
    end
  end
end
