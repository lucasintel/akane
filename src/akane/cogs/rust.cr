module Akane
  module Rust
    include Cog

    URL = "https://play.rust-lang.org/execute"
    HEADER = HTTP::Headers{ "Content-Type" => "application/json" }

    struct Response
      JSON.mapping(
        success: Bool,
        stdout: String,
        stderr: String
      )
    end

    @[Command(
      name: "rustc",
      description: "Compile and execute rust code",
      usage: "(codeblock)"
    )]
    def rustc(client, payload, args)
      return "Invalid format." unless md = args.match(/```rust\n(?<code>.*)```/m)

      request = {
        channel: "stable",
        mode: "debug",
        crateType: "bin",
        tests: false,
        code: md["code"],
        backtrace: false
      }

      res = HTTP::Client.post(URL, HEADER, request.to_json)
      return "Request failed." unless res.success?

      result = Response.from_json(res.body)

      if result.stdout.size >= 1000 || result.stderr.size >= 1000
        return "Result too big."
      end

      Discord::Embed.new(
        title: "Result",
        colour: 6844039_u32,
        fields: [
          Discord::EmbedField.new(name: "stdout", value: result.stdout.code),
          Discord::EmbedField.new(name: "stderr", value: result.stderr.code)
        ],
        footer: Discord::EmbedFooter.new(text: "Success: #{result.success}.")
      )
    end
  end
end
