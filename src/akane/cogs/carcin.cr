module Akane
  module Carcin
    include Cog

    URL = "https://carc.in/run_requests"
    HEADER = HTTP::Headers{ "Content-Type" => "application/json; charset=utf-8" }

    struct Response
      include JSON::Serializable

      getter id : String
      getter language : String
      getter version : String
      getter stdout : String
      getter stderr : String
      getter html_url : String
    end

    private def run_request(lang, code)
      lang, version = lang

      request = {
        run_request: {
          language: lang,
          version: version,
          code: code
        }
      }

      res = HTTP::Client.post(URL, HEADER, request.to_json)
      return unless res.success?

      Response.from_json(res.body, ["run_request", "run"])
    end

    @[Command(
      name: "eval",
      description: "Evaluates C, crystal and ruby code",
      usage: "(codeblock)"
    )]
    def eval(client, payload, args)
      return unless md = payload.content.match(/```(?<language>\w+)\n(?<code>.*)```/m)

      case md["language"]
      when "c", "gcc"
        lang = {"gcc", "6.3.1"}
      when "ruby", "rb"
        lang = {"ruby", "2.5.3"}
      else
        lang = {"crystal", "0.27.0"}
      end

      return unless res = run_request(lang, md["code"])

      fields = [] of Discord::EmbedField

      unless res.stdout.size >= 1000 || res.stderr.size >= 1000
        fields = [
          Discord::EmbedField.new(name: "stdout", value: res.stdout.code),
          Discord::EmbedField.new(name: "stderr", value: res.stderr.code)
        ]
       end

      embed = Discord::Embed.new(
        title: "Result",
        description: res.html_url,
        colour: 6844039_u32,
        fields: fields,
        footer: Discord::EmbedFooter.new(text: "#{res.language} #{res.version}")
      )

      client.create_message(payload.channel_id, "", embed)
    end
  end
end
