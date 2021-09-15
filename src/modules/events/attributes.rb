# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Attributes
      extend Discordrb::EventContainer

      caracs = [
        {
          cmd: '!FOR',
          column: 'force',
          message: 'La FORce de ton personnage est de : '
        },
        {
          cmd: '!INT',
          column: 'intelligence',
          message: "L'INTelligence de ton personnage est de : "
        },
        {
          cmd: '!SAG',
          column: 'sagesse',
          message: 'La SAGesse de ton personnage est de : '
        },
        {
          cmd: '!DEX',
          column: 'dexterite',
          message: 'La DEXtérité de ton personnage est de : '
        },
        {
          cmd: '!CON',
          column: 'constitution',
          message: 'La CONstitution de ton personnage est de : '
        },
        {
          cmd: '!CHA',
          column: 'charisme',
          message: 'Le CHArisme de ton personnage est de : '
        }
      ]

      caracs.each do |c|
        message(content: /^#{c[:cmd]}$/) do |event|
          event.message.delete

          settings = Database::Settings.where(server_id: event.server.id)&.first
          unless event.channel.id == settings.creation_channel_id
            msg = "L'édition de ton personnage doit être réalisée dans le salon "\
            "#{BOT.channel(settings.creation_channel_id).mention}"

            event.respond msg
            next
          end

          charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
          next if charsheet.nil?

          unless charsheet[c[:column].to_sym].zero?
            event.message.delete
            event.respond "Tu as déjà tiré la caractéristique **#{c[:column]}**"
            next
          end

          roll_dice = []

          3.times do
            roll_dice << rand(1..6)
          end

          attribute = roll_dice.sum

          charsheet.update(c[:column].to_sym => attribute)
          charsheet.update_message!

          attributes_pattern = {
            force: 'FOR',
            intelligence: 'INT',
            dexterite: 'DEX',
            sagesse: 'SAG',
            constitution: 'CON',
            charisme: 'CHA'
          }

          att_remain = []

          attributes_pattern.keys.each do |k|
            att_remain << attributes_pattern[k] if (charsheet[k.to_sym]).zero?
          end

          msg = event.user.mention
          msg += "```md\n"
          msg += "#{c[:message]}#{attribute}\n"
          msg += "------\n"
          msg += "Dés : #{roll_dice}\n"
          msg += "Résultat : #{attribute}"
          msg += "```\n"
          if att_remain.length.zero?
            msg += "Lance la commande `!classes` pour choisir la classe de ton personnage. \n"
            msg += '*Seules les classes qui te sont accessibles seront proposées.*'
          else
            msg += "Tu peux continuer à tirer tes caractéristiques restantes :\n"
            att_remain.each do |att|
              msg += " ` !#{att} ` "
            end
          end

          event.respond msg
        end
      end
    end
  end
end
