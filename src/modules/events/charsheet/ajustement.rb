# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Ajustement
      extend Discordrb::EventContainer

      message(content: /^!ajuster$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        caracs_drop = %w[force intelligence sagesse]

        final_drop = []

        caracs_drop.each do |c|
          final_drop << c if charsheet[c.to_sym] >= 11
        end

        if final_drop.length.zero?
          msg = "Ta FORce, ton INTelligence et ta SAG sont **trop bas** pour être diminués.\n\n"
          msg += "Tu peux continuer la création de ton personnage en tirant ses PV Maximum à l'aide de la commande ` !pvmax `"

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)

          next
        end

        msg = "Quelle caractéristique souhaites-tu réduire de 2 points ?\n\n"
        final_drop.each.with_index(1) do |c, index|
          msg += "#{index} :small_orange_diamond: #{c} (#{charsheet[c.to_sym]} -> #{charsheet[c.to_sym] - 2})\n"
        end
        msg += "\n*Seules les caractéristiques supérieures à 11 sont proprosées.*\n"

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @drop = if id.zero?
                    nil
                  else
                    final_drop[id - 1]
                  end

          choice.message.delete
          true
        end

        if @drop.nil?
          event.channel.message(res.id).delete
          msg = "Aucune caractéristique ne correspond à ce chiffre ou temps écoulé.\n\n"
          msg += ":small_blue_diamond: `!ajuster` Continue d'ajuster tes caractéristiques\n"
          msg += ':small_blue_diamond: `!pvmax` Découvre tes **Points de Vie** maximum'

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        event.channel.message(res.id).delete

        attributes_pattern = {
          force: 'FOR',
          intelligence: 'INT',
          dexterite: 'DEX',
          sagesse: 'SAG',
          constitution: 'CON',
          charisme: 'CHA'
        }

        main_att = charsheet.classe.main_attributes.split('|')

        msg_drop = "Tu as choisi de diminuer ta caractéristique **#{@drop}** de 2 points.\n"
        msg = msg_drop
        msg += "\nQuelle caractéristique souhaites-tu augmenter de 1 point ?\n"

        main_att.each.with_index(1) do |c, index|
          mod = c == @drop ? 0 : -2

          msg += "#{index} :small_orange_diamond: #{c} "\
          "(#{charsheet[attributes_pattern.key(c).to_sym] + mod} -> #{charsheet[attributes_pattern.key(c).to_sym] + mod + 1})\n"
        end

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @up = if id.zero?
                  nil
                else
                  attributes_pattern.key(main_att[id - 1])
                end

          choice.message.delete
          true
        end
        if @up.nil?
          event.channel.message(res.id).delete
          msg = "Aucune caractéristique ne correspond à ce chiffre ou temps écoulé.\n\n"
          msg += ":small_blue_diamond: `!ajuster` Continue d'ajuster tes caractéristiques\n"
          msg += ':small_blue_diamond: `!pvmax` Découvre tes **Points de Vie** maximum'

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)

          next
        end

        event.channel.message(res.id).delete

        msg_up = "Tu as choisi d'augmenter ta caractéristique **#{@up}** de 1 point.\n"

        charsheet.update(@drop.to_sym => charsheet[@drop.to_sym] - 2)
        charsheet.update(@up.to_sym => charsheet[@up.to_sym] + 1)
        charsheet.update_message!

        msg = msg_drop
        msg += msg_up
        msg += "\nLa fiche de ton personnage a été mise à jour !\n\n"
        msg += ":small_blue_diamond: `!ajuster` Continue d'ajuster tes caractéristiques\n"
        msg += ':small_blue_diamond: `!pvmax` Découvre tes **Points de Vie** maximum'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
