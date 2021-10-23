# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Destroy Guild
    module GuildDestroy
      extend Discordrb::EventContainer

      message(start_with: /^!(g|guild|guilde){1} (supp|del|destroy){1}/i) do |event|
        next unless event.user.owner?

        guilds = Database::Guild.where(server_id: event.server.id).all

        msg = "Il n'y a pas de guilde sur ce serveur.\n" \
        '`!g new [nom de la guilde]` pour en créer une.'

        event.respond msg and next if guilds.nil?

        msg = "__LISTE DES GUILDES__\n\n"
        guilds.each.with_index(1) do |g, index|
          msg += "#{index} :small_blue_diamond: #{g.name}\n"
        end
        msg += "\n*Réponds en indiquant le chiffre correspondant, ou 0 pour annuler.*"

        embed = Character::Embed.event_message(event, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > guilds.length + 1
            @guild_id = nil
            event.channel.message(res.id).delete

            msg = "Choix d'une guilde annulé."
            embed = Character::Embed.event_message(event, msg)
            event.channel.send_message('', false, embed)
          else
            @guild_id = id - 1
          end

          choice.message.delete
          true
        end
        next if @guild_id.nil?

        event.channel.message(res.id).delete

        guild = guilds[@guild_id]
        @guild_name = guild.name

        guild&.destroy
        # set nil for all characters in this guild

        msg = "La guilde **#{@guild_name}** a été supprimée."

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
