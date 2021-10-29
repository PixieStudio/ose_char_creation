# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module AllAttributes
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} roll (carac|att){1}/i) do |event|
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
          msg = ''
        end
        next if msg.empty?

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

        msg += "\n:small_blue_diamond: `!c classes` pour choisir la classe de ton personnage.\n\n"
        msg += '*Seules les classes qui te sont accessibles seront proposées.*'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
