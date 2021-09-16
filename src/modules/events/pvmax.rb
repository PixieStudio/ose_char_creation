# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Pvmax
      extend Discordrb::EventContainer

      message(content: /^!pvmax$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?
        next unless charsheet[:pv_max].zero?

        mod = charsheet.const_mod

        dice = charsheet.classe.dv.split('').last.to_i

        pv = rand(1..dice)

        pvmax = pv + mod

        pvmax = 1 if pvmax < 1

        msg = "**PV Max - Jet de dés !**\n\n"
        msg += ":heart: DV : #{charsheet.classe.dv}\n\n"
        msg += ":game_die: Jet de dés : #{pv}\n\n"
        msg += ':ox: Modificateur de CONstitution : '
        msg += '+' if mod.positive? || mod.zero?
        msg += mod.to_s
        msg += "\n\n:diamond_shape_with_a_dot_inside: Résultat : #{pvmax}\n\n"
        msg += "Tes points de vie maximum s'élèvent à..... **#{pvmax}** !\n"
        msg += "Bonne chance !\n\n"
        msg += ":small_blue_diamond: ` !gold ` Découvre le nombre de pièces d'or que tu possèdes"

        charsheet.update(pv_max: pvmax)
        charsheet.update_message!

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
