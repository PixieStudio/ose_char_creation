# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Interactive Help
    module Tutorial
      extend Discordrb::Commands::CommandContainer
      command :help do |event|
        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)

        embed = Character::Embed.help_message(event)

        status = false

        if charsheet.nil?
          embed.description = 'Tu peux créer un personnage `!nouveau perso`'
          event.channel.send_message('', false, embed)
          next
        end

        ATTRIBUTES.each do |k, v|
          next unless charsheet[k].zero?

          embed.description = v[:define]
          event.channel.send_message('', false, embed)
          status = true
          break
        end

        break if status

        if charsheet.classe.cle == 'base'
          embed.description = 'Tu peux choisir une classe `!classes`'
          event.channel.send_message('', false, embed)
          next
        end

        unless charsheet.ajuster_protection
          embed.description = "Tu peux ajuster ta ou tes caractéristiques principales `!ajuster`\n"\
          'ou passer directement au tirage de tes Points de Vie maximum `!pvmax`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.pv_max.zero?
          embed.description = 'Tu peux tirer tes Points de Vie maximum `!pvmax`'
          event.channel.send_message('', false, embed)
          next
        end

        unless charsheet.gold_protection
          embed.description = "Tu peux tirer tes Pièces d'or de départ `!gold`"
          event.channel.send_message('', false, embed)
          next
        end

        learned = charsheet.languages.split(', ').count

        if (charsheet.intelligence.between?(13, 15) && learned.zero?) ||
           (charsheet.intelligence.between?(16, 17) && learned < 2) ||
           (charsheet.intelligence == 18 && learned < 3)
          embed.description = 'Tu peux choisir des langues supplémentaires `!langues`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.rumeur == '` !rumeur `'
          embed.description = 'Tu peux tirer une rumeur `!rumeur`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.alignement == '!alignement'
          embed.description = 'Tu peux choisir ton alignement `!alignement`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.char_name == '!nom'
          embed.description = 'Tu peux choisir ton nom `!nom`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.genre == '!pronoms'
          embed.description = 'Tu peux choisir tes pronoms `!pronoms`'
          event.channel.send_message('', false, embed)
          next
        end

        if charsheet.avatar_url == 'https://i.imgur.com/Q7B91HT.png'
          embed.description = 'Tu peux ajouter un portrait à ton personnage `!avatar`'
          event.channel.send_message('', false, embed)
          next
        end

        settings = Character::Check.settings(event)

        creation_cmd = ":moneybag: `!richesses`\n"\
        "Modifie tes PO\n"\
        ":compass: `!pp`\n"\
        "Ajoute un Point de Participation\n"\
        ":headstone: `!mort`\n"\
        'Ton personnage est mort'

        embed.description = 'Commandes supplémentaires'
        embed.add_field name: "##{BOT.channel(settings.merchants_channel_id).name}", value: ":convenience_store: `!marchands`\nAchète aux marchands", inline: true
        embed.add_field name: "##{BOT.channel(settings.creation_channel_id).name}", value: creation_cmd, inline: true
        event.channel.send_message('', false, embed)
      end
    end
  end
end
