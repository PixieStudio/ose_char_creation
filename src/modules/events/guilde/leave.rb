# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Create Guild
    module GuildLeave
      extend Discordrb::EventContainer

      message(start_with: /^!(g|guild|guilde){1} (leave|quit|quitter){1}/i) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Tu ne fais partie d'aucune guilde.\n" \
        '`!g join` pour en rejoindre une.'
        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed) and next if charsheet.guild.nil?

        @guild_name = charsheet.guild.name

        msg = "Es-tu sûr.e de vouloir quitter la guilde **#{@guild_name}** ?\n"

        msg += "\n*Réponds par **oui** pour valider, ou n'importe quoi d'autre pour annuler.*"

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content
          @guild_id = id.match?(/^(oui|yes)$/i) ? nil : 1

          choice.message.delete
          puts @guild_id
          true
        end
        next unless @guild_id.nil?

        event.channel.message(res.id).delete

        charsheet.update(guild_id: nil)
        charsheet.update_message!
        event.message.delete

        msg = "Tu as quitté la guilde **#{@guild_name}**"

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
