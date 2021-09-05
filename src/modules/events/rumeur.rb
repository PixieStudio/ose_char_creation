module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Rumeur
      extend Discordrb::EventContainer

      message(content: /^!rumeur$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        unless event.channel.id == settings.creation_channel_id
          msg = "L'édition de ton personnage doit être réalisée dans le salon "\
          "#{BOT.channel(settings.creation_channel_id).mention}"

          event.respond msg
          next
        end

        charsheet = Database::Character.find_sheet(event.user.id)
        next if charsheet.nil?
        next unless charsheet.rumeur == '` !rumeur `'

        rumeurs = Database::Rumeur.all(settings.server_id)

        rumeur = rumeurs[rand(0..rumeurs.length - 1)]

        rumeur.update(available: false)
        charsheet.update(rumeur: rumeur.content)
        charsheet.update_message!

        msg = event.user.mention
        msg += "\nTu as entendu la rumeur suivante :\n"
        msg += "**#{rumeur.content}**"
        msg += "\n\n*La fiche de ton personnage a été mise à jour !*\n\n"
        msg += 'Il reste encore à définir ton ` !alignement `'

        event.respond msg
      end
    end
  end
end
