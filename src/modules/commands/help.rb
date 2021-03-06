# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Interactive Help
    module Tutorial
      extend Discordrb::Commands::CommandContainer
      command :help do |event|
        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)

        status = false

        if charsheet.nil?
          msg = "Tu peux créer un personnage `!c new`\n"\
          'ou sélectionner un autre personnage que tu possèdes `!c select`'
          Character::Embed.help_message(event, msg)
          next
        end

        ATTRIBUTES.each do |k, v|
          next unless charsheet[k].zero?

          msg = "#{v[:define]}\n:diamond_shape_with_a_dot_inside: #{v[:caracs]}"
          Character::Embed.help_message(event, msg)
          status = true
          break
        end

        break if status

        if charsheet.classe.cle == 'base'
          msg = 'Tu peux choisir une classe `!c classes`'
          Character::Embed.help_message(event, msg)
          next
        end

        unless charsheet.ajuster_protection
          msg = "Tu peux ajuster ta ou tes caractéristiques principales `!c ajuster`\n" \
          'ou passer directement au tirage de tes Points de Vie maximum `!c roll pv`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.pv_max.zero?
          msg = 'Tu peux tirer tes Points de Vie maximum `!c roll pv`'
          Character::Embed.help_message(event, msg)
          next
        end

        unless charsheet.gold_protection
          msg = "Tu peux tirer tes Pièces d'or de départ `!c po`"
          Character::Embed.help_message(event, msg)
          next
        end

        learned = charsheet.languages.split(', ').count

        if (charsheet.intelligence.between?(13, 15) && learned.zero?) ||
           (charsheet.intelligence.between?(16, 17) && learned < 2) ||
           (charsheet.intelligence == 18 && learned < 3)
          msg = 'Tu peux choisir des langues supplémentaires `!c langues`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.rumeur == '` !rumeur `'
          msg = 'Tu peux tirer une rumeur `!rumeur`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.alignement == '!alignement'
          msg = 'Tu peux choisir ton alignement `!c alignement`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.char_name == '!nom'
          msg = 'Tu peux choisir ton nom `!c nom`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.genre == '!pronoms'
          msg = 'Tu peux choisir tes pronoms `!c pronoms`'
          Character::Embed.help_message(event, msg)
          next
        end

        if charsheet.avatar_url == 'https://i.imgur.com/Q7B91HT.png'
          msg = 'Tu peux ajouter un portrait à ton personnage `!c avatar`'
          Character::Embed.help_message(event, msg)
          next
        end

        msg = ''
        Character::Embed.help_message(event, msg)
      end
    end
  end
end
