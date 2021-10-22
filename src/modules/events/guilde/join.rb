# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Create Guild
    module GuildJoin
      extend Discordrb::EventContainer

      message(start_with: /^!(g|guild|guilde){1} (join|rejoindre){1}/i) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        guilds = Database::Guild.where(server_id: event.server.id).all

        msg = "Il n'y a pas de guilde sur ce serveur.\n" \
        '`!g new [nom de la guilde]` pour en créer une.'

        event.respond msg and next if guilds.nil?

        msg = "__LISTE DES GUILDES__\n\n"
        guilds.each.with_index(1) do |g, index|
          msg += "#{index} :small_blue_diamond: #{g.name}\n"
        end
        msg += "\n*Réponds en indiquant le chiffre correspondant, ou 0 pour annuler.*"

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > guilds.length + 1
            @guild_id = nil
            event.channel.message(res.id).delete

            msg = "Choix d'une guilde annulé."
            embed = Character::Embed.char_message(charsheet, msg)
            event.channel.send_message('', false, embed)
          else
            @guild_id = id - 1
          end

          choice.message.delete
          true
        end
        next if @guild_id.nil?

        event.channel.message(res.id).delete

        charsheet.update(guild_id: guilds[@guild_id].id)
        charsheet.update_message!

        msg = "Tu fais, à présent, partie de la guilde **#{charsheet.guild.name}**"

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
