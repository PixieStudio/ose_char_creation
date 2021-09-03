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
          charsheet = Database::Character.find_sheet(event.user.id)

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

          msg = event.user.mention
          msg += "```md\n"
          msg += "#{c[:message]}#{attribute}\n"
          msg += "------\n"
          msg += "Dés : #{roll_dice}\n"
          msg += "Résultat : #{attribute}"
          msg += '```'

          event.respond msg
        end
      end
    end
  end
end
