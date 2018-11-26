require "myhtml"

module Akane
  module Boatos
    include Cog

    private def generate_embed(description, title = "", url = "", image = "", published_at = nil)
      case published_at
      when String
        timestamp = Time.parse(published_at, "%d/%m/%Y", Time::Location.local)
      when Nil
        timestamp = Time.now
      end

      Discord::Embed.new(
        author: Discord::EmbedAuthor.new(
          name: "Boatos.org",
          url: "https://www.boatos.org/"
        ),
        title: title,
        image: Discord::EmbedImage.new(url: image.as(String)),
        url: url,
        description: description,
        timestamp: timestamp
      )
    end

    @[Command(
      name: "boato",
      description: "Busque por boatos",
      usage: "...",
      hidden: true
    )]
    def boato(client, payload, args)
      res = HTTP::Client.get("https://www.boatos.org/?s=#{args.tr(" ", "+")}")
      return unless res.success?

      articles = Myhtml::Parser.new(res.body).nodes(:article)
      return unless articles

      if articles.size > 1
        links = articles.each_with_object([] of String) do |article, links|
          link = article.css(".entry-title a").first
          links << "- [#{link.inner_text}](#{link.attribute_by("href")})"
        end

        embed = generate_embed(description: links[0..5].join("\n"))
      else
        article = articles.first

        image_url = article.css(".featured-image img")
                           .first?.try(&.attribute_by("src").as(String))

        link = article.css(".entry-title a").first

        embed = generate_embed(
          title: link.inner_text,
          url: link.attribute_by("href").as(String),
          image: image_url,
          description: article.css(".entry-content p").first.inner_text,
          published_at: article.css(".entry-date").first.inner_text
        )
      end

      client.create_message(payload.channel_id, "", embed)
    end
  end
end
