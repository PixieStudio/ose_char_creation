# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module AddRumeur
      extend Discordrb::EventContainer

      message(content: /^!add rumeurs$/) do |event|
        event.message.delete

        next unless event.user.owner?

        msg = 'Les rumeurs sont uniques. Une fois attribuée à un joueur, la rumeur deviendra indisponible.'
        msg += 'Tape les rumeurs à ajouter au serveur. 1 ligne = 1 rumeur'

        res = event.respond msg

        event.user.await!(timeout: 300) do |guess_event|
          @rumeurs = guess_event.message.content.split("\n")
          true
        end

        @rumeurs.each do |r|
          rumeur = Database::Rumeur.create(
            server_id: event.server.id,
            content: r
          )
          rumeur.save
        end

        res.delete

        msg = "#{@rumeurs.length} rumeurs ont été ajoutées à la base de données."
        msg += "Tu peux ajouter de nouvelles rumeurs à l'aide de la commande ` !add rumeurs `"

        event.respond msg
      end
    end
  end
end
