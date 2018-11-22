module Akane
  class Cache
    alias Snowflake = Discord::Snowflake | UInt64

    def initialize(@client : Discord::Client)
    end

    def resolve_user(id : Snowflake) : Discord::User
      if user = REDIS.get("user:#{id}")
        Discord::User.from_json(user)
      else
        @client.get_user(id).tap { |u| cache(u) }
      end
    end

    def resolve_channel(id : Snowflake) : Discord::Channel
      if channel = REDIS.get("channel:#{id}")
        Discord::Channel.from_json(channel)
      else
        @client.get_channel(id).tap { |c| cache(c) }
      end
    end

    def resolve_guild(id : Snowflake) : Discord::Guild
      if guild = REDIS.get("guild:#{id}")
        Discord::Guild.from_json(guild)
      else
        @client.get_guild(id).tap { |g| cache(g) }
      end
    end

    def resolve_member(gid : Snowflake, uid : Snowflake) : Discord::GuildMember
      if member = REDIS.get("member:#{gid}:#{uid}")
        Discord::GuildMember.from_json(member)
      else
        @client.get_guild_member(gid, uid).tap { |g| cache(g, gid) }
      end
    end

    def resolve_role(id : Snowflake) : Discord::Role?
      role = REDIS.get("role:#{id}")
      return unless role

      Discord::Role.from_json(role)
    end

    def resolve_dm_channel(rid : Snowflake)
    end

    def resolve_current_user : Discord::User
      if me = REDIS.get("@me")
        Discord::User.from_json(me)
      else
        @client.get_current_user.tap { |u| cache_current_user(u) }
      end
    end

    def cache_current_user(user : Discord::User)
      REDIS.set("@me", user.to_json)
    end

    def cache_dm_channel(cid : Snowflake, rid : Snowflake)
    end

    def add_guild_channel(gid : Snowflake, cid : Snowflake)
      channels = Array(Snowflake).from_json(REDIS.get("channels:#{gid}") || "[]")
      channels << cid

      REDIS.set("channels:#{gid}", channels.uniq!.to_json)
    end

    def remove_guild_channel(gid : Snowflake, cid : Snowflake)
      channels = Array(Snowflake).from_json(REDIS.get("channels:#{gid}") || "[]")
      return if channels.empty?

      REDIS.set("channels:#{gid}", channels.reject(&.== cid).to_json)
    end

    def add_guild_role(gid : Snowflake, rid : Snowflake)
      roles = Array(Snowflake).from_json(REDIS.get("roles:#{gid}") || "[]")
      roles << rid

      REDIS.set("roles:#{gid}", roles.uniq!.to_json)
    end

    def remove_guild_role(gid : Snowflake, rid : Snowflake)
      roles = Array(Snowflake).from_json(REDIS.get("roles:#{gid}") || "[]")
      return if roles.empty?

      REDIS.set("roles:#{gid}", roles.reject(&.== rid).to_json)
    end

    def cache(channel : Discord::Channel)
      REDIS.set("channel:#{channel.id}", channel.to_json)
    end

    def cache(guild : Discord::Guild)
      REDIS.set("guild:#{guild.id}", guild.to_json)
    end

    def cache(role : Discord::Role)
      REDIS.set("role:#{role.id}", role.to_json)
    end

    def cache(member : Discord::GuildMember, gid : Snowflake)
      REDIS.set("member:#{gid}:#{member.user.id}", member.to_json)
    end

    def cache(user : Discord::User)
      REDIS.set("user:#{user.id}", user.to_json)
    end

    def delete_channel(id : Snowflake)
      REDIS.del("channel:#{id}")
    end

    def delete_guild(id : Snowflake)
      REDIS.del("guild:#{id}")
    end

    def delete_member(gid : Snowflake, uid : Snowflake)
      REDIS.del("member:#{gid}:#{uid}")
    end

    def delete_role(id : Snowflake)
      REDIS.del("role:#{id}")
    end

    def delete_user(id : Snowflake)
      REDIS.del("user:#{id}")
    end

    def delete_dm_channel(rid : Snowflake)
    end

    def delete_current_user
      REDIS.del("@me")
    end

    def cache_multiple_members(members : Array(Discord::GuildMember), gid : Snowflake)
      members.each { |member| cache(member, gid) }
    end
  end
end
