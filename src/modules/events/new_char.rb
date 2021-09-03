module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module NewChar
      extend Discordrb::EventContainer

      message(content: /^!nouveau perso.*$/i) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        next unless event.channel.id == settings.creation_channel_id

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
        msg += '`!FOR` `!INT` `!SAG` `!DEX` `!CON` `!CHA`'

        event.respond msg
      end
    end
  end
end
