# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Settings
      extend Discordrb::EventContainer
      message(content: /^!settings$/i) do |event|
        event.message.delete

        next unless event.user.owner?

        msg = "**:tools: Définir les salons**\n"
        msg += "`!set channel creation`\n"
        msg += "Où les joueurs créent leur personnage.\n\n"
        msg += "`!set channel charsheet`\n"
        msg += "Où les feuilles de personnages seront postées.\n\n"
        msg += "`!set channel merchants`\n"
        msg += "Dédié au commerce avec les marchands.\n\n"
        msg += "`!set channel graveyard`\n"
        msg += "Cimetière des personnages.\n\n"

        embed = Character::Embed.event_message(event, msg)
        embed.title = 'Commandes de configuration'

        event.channel.send_message('', false, embed)
      end
    end
  end
end
