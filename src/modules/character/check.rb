# frozen_string_literal: true

module Bot
  module Character
    module Check
      def self.channel(event)
        settings = Database::Settings.where(server_id: event.server.id)&.first
        return true if event.channel.id == settings.creation_channel_id

        msg = "L'édition de ton personnage doit être réalisée dans le salon "\
        "#{BOT.channel(settings.creation_channel_id).mention}"

        event.respond msg
        false
      end
    end
  end
end
