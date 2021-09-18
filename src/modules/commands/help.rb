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

        puts 'OK'
      end
    end
  end
end
