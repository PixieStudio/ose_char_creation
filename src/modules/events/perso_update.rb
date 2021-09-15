# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module PersoUpdate
      extend Discordrb::EventContainer

      message(content: /^!update perso$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        unless event.channel.id == settings.creation_channel_id
          msg = "L'édition de ton personnage doit être réalisée dans le salon "\
          "#{BOT.channel(settings.creation_channel_id).mention}"

          event.respond msg
          next
        end

        if event.user.owner?
          charsheets = Database::Character.where(server_id: event.server.id).all

          msg = 'Toutes les fiches personnages ont été mises à jour.'

          charsheets.each do |c|
            c.update_message!
          end

        else
          charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
          next if charsheet.nil?

          msg = "#{event.user.mention} Ta fiche personnage a été mise à jour."

          charsheet.update_message!
        end

        event.respond msg
      end
    end
  end
end
