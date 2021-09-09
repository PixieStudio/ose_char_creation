module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Attributes
      extend Discordrb::EventContainer

      message(content: /^!gold$/) do |event|
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
        next unless charsheet.gold.zero?

        roll_dice = []

        3.times do
          roll_dice << rand(1..6)
        end

        gold = roll_dice.sum * 10

        charsheet.update(gold: gold)
        charsheet.update_message!

        msg = event.user.mention
        msg += "```md\n"
        msg += "Pièces d'or de départ\n"
        msg += "------\n"
        msg += "Dés : ( #{roll_dice} ) x 10\n"
        msg += "Résultat : #{gold}"
        msg += "```\n"
        msg += "La fiche de ton personnage a été mise à jour. \n\n"
        msg += 'Découvre, à présent, la rumeur que tu as entendu grâce à la commande ` !rumeur `'

        event.respond msg
      end
    end
  end
end
