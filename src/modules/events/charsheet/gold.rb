# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Attributes
      extend Discordrb::EventContainer

      message(content: /^!gold$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        if charsheet.gold_protection
          msg = "#{charsheet.char_name} possède **#{charsheet.gold}** Pièces d'or."
          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        roll_dice = []

        3.times do
          roll_dice << rand(1..6)
        end

        gold = roll_dice.sum * 10

        charsheet.update(gold: gold, gold_protection: true)
        charsheet.update_message!

        msg = "**Pièces d'or de départ**\n\n"
        msg += ":game_die:  Dés : ( #{roll_dice.join(' + ')} ) x 10\n\n"
        msg += ":diamond_shape_with_a_dot_inside:  Résultat : #{gold}\n\n"
        msg += "Ton personnage commence avec **#{gold}** Pièces d'Or !\n\n"
        msg += "*La fiche de ton personnage a été mise à jour.* \n\n"
        msg += '` !rumeur ` Découvre la rumeur que tu as entendue.'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
