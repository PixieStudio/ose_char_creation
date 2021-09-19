# frozen_string_literal: true

module Bot
  module Character
    # Check condition
    module Check
      def self.settings(event)
        Database::Settings.where(server_id: event.server.id)&.first
      end

      def self.set?(event)
        settings = settings(event)

        if settings.nil?
          msg = "Le propriétaire du serveur doit d'abord configurer le Bot à l'aide de la commande  `!settings`"
          embed = Character::Embed.event_message(event, msg)

          event.channel.send_message('', false, embed)
          return false
        end

        settings
      end

      def self.creation_channel?(event)
        settings = settings(event)

        return false if set?(event) == false

        return settings if event.channel.id == settings.creation_channel_id

        msg = "L'édition de ton personnage doit être réalisée dans le salon "\
        "#{BOT.channel(settings.creation_channel_id).mention}"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
        false
      end

      def self.rumeurs?(event)
        rumeurs = Database::Rumeur.all(settings(event).server_id)
        return false unless rumeurs.empty?

        msg = "Le propriétaire du serveur doit d'abord ajouter des rumeurs.\nCommande `!add rumeurs`"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
        true
      end

      def self.all(event)
        settings = creation_channel?(event)
        return false if settings == false

        return false if rumeurs?(event) == true

        settings
      end

      def self.merchants?(event)
        settings = settings(event)

        return false if settings.merchants_channel_id.nil?

        return settings if event.channel.id == settings.merchants_channel_id

        msg = "Le commerce s'effectue dans le salon "\
        "#{BOT.channel(settings.merchants_channel_id).mention}"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
        false
      end
    end
  end
end
