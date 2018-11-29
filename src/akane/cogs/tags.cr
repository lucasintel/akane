module Akane
  module Tag
    include Cog

    ATTACH_DIR = "./data/tags"

    struct Tag
      ::DB.mapping(
        id: Int32,
        guild_id: Int64,
        user_id: Int64,
        name: String,
        content: String,
        attachment: String?,
        updated_at: Time,
        created_at: Time
      )

      def file
        File.open("#{ATTACH_DIR}/#{attachment}")
      end

      def self.find(gid, id)
        DB::PG.connection do |pg|
          from_rs(pg.query(DB.find_tag, gid, id))
        end
      end

      def self.exists?(gid, id)
        DB::PG.connection do |pg|
          pg.query_one?(DB.tag_exists, gid, id, as: Int32) == 1
        end
      end
    end

    @[Command(
      name: "tag",
      description: "Create a custom tag and display it on command",
      usage: "(name)"
    )]
    def tag(client, payload, args)
      return "Tag not found." unless tag = Tag.find(payload.guild_id, args).first?

      if tag.attachment
        client.upload_file(payload.channel_id, tag.content, tag.file)
      else
        client.create_message(payload.channel_id, tag.content)
      end
    end

    @[SubCommand("tag", "--create", "(name) (...)")]
    def tag_create(client, payload, args)
      return "What is the tag name?" unless tag_name = args.split.first?
      return "Tag already exists." if Tag.exists?(payload.guild_id, tag_name)

      content = args.sub(tag_name, "")

      if attach = payload.attachments.first?
        HTTP::Client.get(attach.url) do |res|
          File.write("#{ATTACH_DIR}/#{attach.id}_#{attach.filename}", res.body_io)
        end
      end

      return "Missing content." if !attach && content.empty?

      DB.insert_tag(
        guild_id: payload.guild_id.as(Discord::Snowflake),
        user_id: payload.author.id,
        name: tag_name,
        attachment: payload.attachments.first?.try { |a| "#{a.id}_#{a.filename}" },
        content: content.lchop
      )

      "Tag successfully created."
    end

    @[SubCommand("tag", "--delete", "(name)")]
    def tag_delete(client, payload, args)
      return "Tag not found." unless tag = Tag.find(payload.guild_id, args).first?
      return "You can't delete someone else's tag." unless tag.user_id.to_u64 == payload.author.id

      DB.delete_tag(payload.guild_id.as(Discord::Snowflake), tag.name)

      "Tag successfully deleted."
    end
  end
end
