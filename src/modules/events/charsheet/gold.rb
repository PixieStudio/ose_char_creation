# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Attributes
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} (gold|richesse|po){1}/i) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        # Starting Gold
        unless charsheet.gold_protection
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
          msg += ':small_blue_diamond: ` !rumeur ` Découvre la rumeur que tu as entendue.'

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        # Gold Management
        /^!(c|char|perso){1}(nnage|acter){0,1} (gold|richesse|po){1}+s{0,1} (?<action>add|ajouter|ajout|\+|-|remove|retirer){1}\s*(?<amount>\d+)+/i =~ event.message.content

        if amount.nil? || action.nil?
          msg = "Tu dois indiquer une action et un montant\n*Exemple :* `!c po ajout 100`"
          embed = Character::Embed.event_message(event, msg)

          event.channel.send_message('', false, embed)
          next
        end

        if action.match?(/(add|ajouter|ajout|\+)/i)
          @gold = charsheet.gold + amount.to_i
          @mod_gold = '+'
        else
          @gold = charsheet.gold - amount.to_i
          @mod_gold = '-'
        end

        @old_gold = charsheet.gold

        charsheet.update(gold: @gold)
        charsheet.update_message!
        event.message.delete

        msg = "Or modifié : **#{@mod_gold}#{amount} PO**"
        msg += "\n#{@old_gold}  :arrow_right:  #{@gold}\n\n"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
