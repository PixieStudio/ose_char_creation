module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Ajustement
      extend Discordrb::EventContainer

      message(content: /^!ajuster$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        next unless event.channel.id == settings.creation_channel_id

        charsheet = Database::Character.find_sheet(event.user.id)

        caracs_drop = %w[force intelligence sagesse]
        caracs = %w[force intelligence sagesse dexterite constitution charisme]

        final_drop = []

        caracs_drop.each do |c|
          final_drop << c if charsheet[c.to_sym] >= 11
        end

        if final_drop.length.zero?
          msg = event.user.mention
          msg += "\nTa FORce, ton INTelligence et ta SAG sont **trop bas** pour être diminués.\n"
          msg += "Tu peux continuer la création de ton personnage en tirant ses PV Maximum à l'aide de la commande ` !pvmax `"

          event.respond msg

          next
        end

        msg = event.user.mention
        msg += "\nQuelle caractéristique souhaites-tu réduire de 2 points ?\n"
        msg += "*Seules les caractéristiques supérieures à 11 seront proprosées.*\n"
        msg += "```md\n"
        final_drop.each.with_index(1) do |c, index|
          msg += "#{index}. #{c} (#{charsheet[c.to_sym]} -> #{charsheet[c.to_sym] - 2})\n"
        end
        msg += '```'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @drop = if id.zero?
                    nil
                  else
                    final_drop[id - 1]
                  end

          if @drop.nil?
            msg = event.respond 'Aucune caractéristique ne correspond à ce chiffre. Tape ` !ajuster ` à nouveau.'
          else
            choice.message.delete
            true
          end
        end

        res.delete
        msg = "#{event.user.mention} Tu as choisi de diminuer ta caractéristique **#{@drop}** de 2 points."

        event.respond msg

        msg = event.user.mention
        msg = "\nQuelle caractéristique souhaites-tu augmenter de 1 point ?\n"
        msg += "```md\n"
        caracs.each.with_index(1) do |c, index|
          msg += "#{index}. #{c} (#{charsheet[c.to_sym]} -> #{charsheet[c.to_sym] + 1})\n"
        end
        msg += '```'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @up = if id.zero?
                  nil
                else
                  caracs[id - 1]
                end

          if @up.nil?
            msg = event.respond 'Aucune caractéristique ne correspond à ce chiffre. Tape ` !ajuster ` à nouveau.'
          else
            choice.message.delete
            true
          end
        end

        res.delete
        msg = "#{event.user.mention} Tu as choisi de diminuer ta caractéristique **#{@up}** de 1 point."

        event.respond msg

        charsheet.update(@drop.to_sym => charsheet[@drop.to_sym] - 2)
        charsheet.update(@up.to_sym => charsheet[@up.to_sym] + 1)
        charsheet.update_message!

        event.respond "#{event.user.mention} La fiche de ton personnage a été mise à jour !"
      end
    end
  end
end
