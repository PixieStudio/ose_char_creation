# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module PersoUpdate
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} (update|maj|sync){1}/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        if event.user.owner?
          charsheets = Database::Character.where(server_id: event.server.id).where(death: false).all
          return if charsheets.nil?

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
