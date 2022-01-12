# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module PersoUpdate
      extend Discordrb::EventContainer

      message(start_with: /^!c hard update \d+/i) do |event|
        char_id = event.message.content.sub(/^!c hard update /i, '')

        if event.user.id == 183984518414336000
          charsheets = Database::Character.where(id: char_id.to_i).all;
          return if charsheets.nil?

          msg = "La fiche #{char_id} a été mise à jour";

          # tester si condition char_id = all, all char alive else id only;

          charsheets.each do |c|
            c.update_message!
          end

          event.message.delete
          event.respond msg
        end
      end

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
