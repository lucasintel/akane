# Ignore both your own and other bots' messages
# https://github.com/meew0/discord-bot-best-practices
module Discord
  module REST
    def create_message( channel_id : UInt64 | Discord::Snowflake,
                        content : String,
                        embed : Embed? = nil,
                        tts : Bool = false )

      content = "\u200B#{content}" unless content.empty?

      previous_def(channel_id, content, embed, tts)
    end
  end
end

class Myhtml::Iterator::Collection
  def [](id)
    Node.new(@tree, @list[id])
  end
end

class String
  def code(lang = nil)
    "```#{lang}\n#{self}\n```"
  end
end

# FIXME onii-chan
class Object
  def self.from_json(string_or_io, root : Array(String)) : self
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!(root[0]) do
      parser.on_key!(root[1]) do
          new parser
      end
    end
  end
end
