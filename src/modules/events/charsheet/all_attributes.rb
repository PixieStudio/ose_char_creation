# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module AllAttributes
      extend Discordrb::EventContainer

      message(content: /^!caracs|!carac$/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = ''

        ATTRIBUTES.each do |_k, c|
          if charsheet[c[:column]].zero?
            msg += "__JETS DE CARACTÉRISTIQUES__\n\n"
            break
          end
          msg = nil
        end
        next if msg.nil?

        ATTRIBUTES.each do |_k, c|
          next unless charsheet[c[:column]].zero?

          roll_dice = []

          3.times do
            roll_dice << rand(1..6)
          end

          attribute = roll_dice.sum

          charsheet.update(c[:column] => attribute)

          msg += ":game_die: #{c[:column]} : #{roll_dice} = **#{attribute}**\n"
        end

        charsheet.update_message!

        msg += "\n:small_blue_diamond: `!classes` pour choisir la classe de ton personnage.\n\n"
        msg += '*Seules les classes qui te sont accessibles seront proposées.*'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
