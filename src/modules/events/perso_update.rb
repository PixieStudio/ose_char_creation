module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module PersoUpdate
      extend Discordrb::EventContainer

      message(content: /^!update perso$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        next unless event.channel.id == settings.creation_channel_id

        charsheet = Database::Character.find_sheet(event.user.id)
        next if charsheet.nil?

        msg = "#{event.user.mention} Ta fiche personnage a été mise à jour."

        charsheet.update_message!

        event.respond msg
      end
    end
  end
end
