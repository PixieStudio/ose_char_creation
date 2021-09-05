module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module NewChar
      extend Discordrb::EventContainer

      message(content: /^!nouveau perso.*$/i) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        if settings.nil?
          msg = "Le propriétaire du serveur doit d'abord configurer le Bot à l'aide de la commande ` !settings `"

          event.respond msg
          next
        end

        unless event.channel.id == settings.creation_channel_id
          msg = "L'édition de ton personnage doit être réalisée dans le salon "\
          "#{BOT.channel(settings.creation_channel_id).mention}"

          event.respond msg
          next
        end

        rumeurs = Database::Rumeur.all(settings.server_id)
        if rumeurs.empty?
          msg = "Le propriétaire du serveur doit d'abord ajouter des rumeurs. Commande ` !add rumeurs `"

          event.respond msg
          next
        end

        msg = event.respond 'Création du personnage'

        classe = Database::Classe.find(cle: 'base')

        new_player = Database::Character.create(
          user_discord_id: event.user.id,
          server_id: event.server.id,
          classe: classe
        )

        new_player.save

        fiche = BOT.channel(settings.sheet_channel_id)
        fiche.send_message(BOT.user(event.user.id).mention, false, nil)
        fiche_msg = fiche.send_message('', false, new_player.generate_embed(new_player[:id]))

        new_player.update(message_id: fiche_msg.id)

        msg.delete

        msg = "#{BOT.user(event.user.id).mention}, la fiche de ton personnage a bien été crée dans le salon #{BOT.channel(settings.sheet_channel_id).mention}\n"
        msg += "Pour tirer tes caractéristiques, lance les commandes suivantes au fur et à mesure :\n"
        msg += '` !FOR ` ` !INT ` ` !SAG ` ` !DEX ` ` !CON ` ` !CHA `'

        event.respond msg
      end
    end
  end
end
