module Akane
  module Coliru
    include Cog

    URL = "http://coliru.stacked-crooked.com/compile"
    HEADER = HTTP::Headers{ "Content-Type" => "application/json" }

    @[Command(
      name: "coliru",
      description: "Compile and execute C++ code",
      category: "Programming",
      usage: "(cpp codeblock)"
    )]
    def coliru(client, payload, args)
      return "Invalid format." unless md = args.match(/```cpp\n(?<code>.*)```/m)

      request = {
        cmd: "g++ -std=c++17 -O2 -Wall -pedantic -pthread main.cpp && ./a.out",
        src: md["code"]
      }

      res = HTTP::Client.post(URL, HEADER, request.to_json)
      return "Request failed." unless res.success?

      return "Result too big." if res.body.size >= 1000

      Discord::Embed.new(
        title: "Result",
        colour: 6844039_u32,
        description: res.body.code,
        footer: Discord::EmbedFooter.new(text: request[:cmd])
      )
    end
  end
end
