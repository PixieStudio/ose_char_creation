# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Interactive Help
    module Tutorial
      extend Discordrb::Commands::CommandContainer
      command :help do |event|
        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)

        # embed = Character::Embed.help_message(event)

        status = false

        if charsheet.nil?
          msg = "Tu peux créer un personnage `!nouveau perso`\n"\
          'ou sélectionner un autre personnage que tu possèdes `!persos`'
          # event.channel.send_message('', false, embed)
          Character::Embed.help_message(event, msg)
          next
        end

        ATTRIBUTES.each do |k, v|
          next unless charsheet[k].zero?

          msg = v[:define]
          # event.channel.send_message('', false, embed)
          Character::Embed.help_message(event, msg)
          status = true
          break
        end

        break if status

        if charsheet.classe.cle == 'base'
          msg = 'Tu peux choisir une classe `!classes`'
          Character::Embed.help_message(event, msg)
          next
        end

        unless charsheet.ajuster_protection
          msg = "Tu peux ajuster ta ou tes caractéristiques principales `!ajuster`\n"\
          'ou passer directement au tirage de tes Points de Vie maximum `!pvmax`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.pv_max.zero?
          msg = 'Tu peux tirer tes Points de Vie maximum `!pvmax`'
          Character::Embed.help_message(event, msg)
          next
        end

        unless charsheet.gold_protection
          msg = "Tu peux tirer tes Pièces d'or de départ `!gold`"
          Character::Embed.help_message(event, msg)
          next
        end

        learned = charsheet.languages.split(', ').count

        if (charsheet.intelligence.between?(13, 15) && learned.zero?) ||
           (charsheet.intelligence.between?(16, 17) && learned < 2) ||
           (charsheet.intelligence == 18 && learned < 3)
          msg = 'Tu peux choisir des langues supplémentaires `!langues`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.rumeur == '` !rumeur `'
          msg = 'Tu peux tirer une rumeur `!rumeur`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.alignement == '!alignement'
          msg = 'Tu peux choisir ton alignement `!alignement`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.char_name == '!nom'
          msg = 'Tu peux choisir ton nom `!nom`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.genre == '!pronoms'
          msg = 'Tu peux choisir tes pronoms `!pronoms`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.avatar_url == 'https://i.imgur.com/Q7B91HT.png'
          msg = 'Tu peux ajouter un portrait à ton personnage `!avatar`'
          Character::Embed.help_message(event, msg)
          next
        end

        # settings = Character::Check.settings(event)

        # creation_cmd = ":moneybag: `!richesses`\n"\
        # "Modifie tes PO\n"\
        # ":compass: `!pp`\n"\
        # "Ajoute un Point de Participation\n"\
        # ":headstone: `!mort`\n"\
        # 'Ton personnage est mort'

        # embed.description = 'Commandes supplémentaires'
        # embed.add_field name: "##{BOT.channel(settings.merchants_channel_id).name}", value: ":convenience_store: `!marchands`\nAchète aux marchands", inline: true
        # embed.add_field name: "##{BOT.channel(settings.creation_channel_id).name}", value: creation_cmd, inline: true
        # event.channel.send_message('', false, embed)
        msg = ''
        Character::Embed.help_message(event, msg)
      end
    end
  end
end
