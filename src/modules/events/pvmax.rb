# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Pvmax
      extend Discordrb::EventContainer

      message(content: /^!pvmax$/) do |event|
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
        next unless charsheet[:pv_max].zero?

        mod = charsheet.const_mod

        dice = charsheet.classe.dv.split('').last.to_i

        pv = rand(1..dice)

        pvmax = pv + mod

        pvmax = 1 if pvmax < 1

        msg = event.user.mention
        msg += "Tes points de vie maximum s'élèvent à....... **#{pvmax}** ! Bonne chance !"
        msg += "```md\n"
        msg += "PV Max - Jet de dés !\n"
        msg += "------\n"
        msg += "DV : #{charsheet.classe.dv}\n"
        msg += "Jet de dés : #{pv}\n"
        msg += 'Modificateur de CONstitution : '
        msg += '+' if mod.positive? || mod.zero?
        msg += mod.to_s
        msg += "\nRésultat : #{pvmax}\n"
        msg += "```\n\n"
        msg += "Pour découvrir le nombre de pièce d'or que tu possèdes, tape la commande ` !gold `"

        charsheet.update(pv_max: pvmax)
        charsheet.update_message!

        event.respond msg
      end
    end
  end
end
