# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module AddRumeur
      extend Discordrb::EventContainer

      message(start_with: /^!set (rumor|rumeur){1}/i) do |event|
        event.message.delete

        next unless event.user.owner?

        msg = "Les rumeurs sont uniques. Une fois attribuée à un joueur, la rumeur deviendra indisponible.\n"\
        'Tape les rumeurs à ajouter au serveur. 1 ligne = 1 rumeur'

        embed = Character::Embed.event_message(event, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |guess_event|
          @rumeurs = guess_event.message.content.split("\n")
          guess_event.message.delete
          true
        end

        @rumeurs.each do |r|
          rumeur = Database::Rumeur.create(
            server_id: event.server.id,
            content: r
          )
          rumeur.save
        end

        event.channel.message(res.id).delete

        msg = "#{@rumeurs.length} rumeurs ont été ajoutées à la base de données.\n"
        @rumeurs.each do |r|
          msg += "- #{r}\n"
        end
        msg += "\nTu peux ajouter de nouvelles rumeurs à l'aide de la commande ` !add rumeurs `"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
