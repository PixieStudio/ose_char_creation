# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Nouveau perso
    module NewChar
      extend Discordrb::EventContainer

      message(content: /^!nouveau perso.*$/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        classe = Database::Classe.find(cle: 'base')

        embed = Character::Embed.event_message(event, "Création du personnage...\nVeuillez patienter...")
        res = event.channel.send_message('', false, embed)

        new_player = Database::Character.create(
          user_discord_id: event.user.id,
          server_id: event.server.id,
          classe: classe
        )

        new_player.save

        # chars = Database::Character.char_owned(event.user.id, event.server.id)
        Database::Character.select_char(new_player.id, event.user.id, event.server.id)

        fiche = BOT.channel(settings.sheet_channel_id)
        fiche_msg = fiche.send_message('', false, new_player.generate_embed(new_player[:id]))

        new_player.update(message_id: fiche_msg.id)

        event.channel.message(res.id).delete

        embed = Character::Embed.new_event(event)
        embed.description = 'La fiche de ton personnage a été créée dans le salon '\
        "#{BOT.channel(settings.sheet_channel_id).mention}\n\n"\
        "Commence par tirer tes caractéristiques à l'aide de l'une des commandes suivantes\n"\
        '` !FOR ` ` !INT ` ` !SAG ` ` !DEX ` ` !CON ` ` !CHA `'
        embed.footer = Character::Embed.footer_char
        event.channel.send_message('', false, embed)
      end
    end
  end
end
