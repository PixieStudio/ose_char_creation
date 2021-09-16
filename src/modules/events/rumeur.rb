# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Rumeur
      extend Discordrb::EventContainer

      message(content: /^!rumeur$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        # next unless charsheet.rumeur == '` !rumeur `'

        rumeurs = Database::Rumeur.all(settings.server_id)

        rumeur = rumeurs[rand(0..rumeurs.length - 1)]

        rumeur.update(available: false)

        rumor = charsheet.rumeur == '` !rumeur `' ? rumeur.content : "#{charsheet.rumeur}|#{rumeur.content}"

        charsheet.update(rumeur: rumor)
        charsheet.update_message!

        msg = "**Rumeur**\n\n"
        msg += "#{rumeur.content}\n\n"
        msg += "*La fiche de ton personnage a été mise à jour !*\n\n"
        msg += "` !alignement ` Choisis l'alignement de ton personnage" if charsheet.alignement == '` !alignement `'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
