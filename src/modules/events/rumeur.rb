module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Rumeur
      extend Discordrb::EventContainer

      message(content: /^!rumeur$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        next unless event.channel.id == settings.creation_channel_id

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
        msg += "\n\nLa fiche de ton personnage a été mise à jour !"

        # if args == c[:cmd] || args.length < c[:min_length]
        #   msg = event.respond "#{event.user.mention} #{c[:question]}"
        #   event.user.await!(timeout: 300) do |guess_event|
        #     if guess_event.message.content.length < c[:min_length]
        #       guess_event.respond c[:error]
        #       false
        #     else
        #       charsheet.update(c[:column].to_sym => guess_event.message.content)
        #       puts guess_event.message.content
        #       guess_event.message.delete
        #       msg.delete
        #       true
        #     end
        #   end
        # else
        #   charsheet.update(c[:column].to_sym => args)
        #   puts args
        # end
        # charsheet.update_message!

        # msg = "#{event.user.mention} Ta fiche personnage a été mise à jour."

        event.respond msg
      end
    end
  end
end
