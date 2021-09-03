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

        attributes = []

        6.times do
          roll_dice = []
          3.times do
            roll_dice << rand(1..6)
          end
          attributes << roll_dice.sum
        end

        new_player = Database::Character.create(
          user_discord_id: event.user.id,
          classe: classe,
          force: attributes[0],
          intelligence: attributes[1],
          sagesse: attributes[2],
          dexterite: attributes[3],
          constitution: attributes[4],
          charisme: attributes[5]
        )
        new_player.save

        fiche = BOT.channel(settings.sheet_channel_id)
        fiche.send_message(BOT.user(event.user.id).mention, false, nil)
        fiche_msg = fiche.send_message('', false, new_player.generate_embed(new_player[:id]))

        new_player.update(message_id: fiche_msg.id)

        msg.delete

        msg = "#{BOT.user(event.user.id).mention}, la fiche de ton personnage a bien été crée dans le salon #{BOT.channel(settings.sheet_channel_id).mention}\n"
        msg += "Pour continuer la création de ton personnage, tape la commande :\n"
        msg += '`!classes`'

        event.respond msg
      end
    end
  end
end
