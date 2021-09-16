# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module CharAvatar
      extend Discordrb::EventContainer

      message(content: /^!avatar$/) do |event|
        event.message.delete

        settings = Character::Check.channel(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        embed = Character::Embed.new_event(event)
        embed.description = "Pour ajouter l'avatar de ton personnage à sa feuille, écrit l'URL de celle-ci.\n"\
        "*Exemple : https://i.imgur.com/Q7B91HT.png .*\n"
        embed.footer = Character::Embed.cancel

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          @url = choice.message.content

          if @url == '0'
            event.channel.message(res.id).delete
            embed = Character::Embed.new_event(event)
            embed.description = "Tu as annulé l'ajout d'un avatar.\n"\
            "Tu peux recommencer à tout moment à l'aide de la commande `!avatar`"
            embed.timestamp = Time.now

            event.channel.send_message('', false, embed)
            true
          end
          choice.message.delete
          true
        end
        next if @url == '0'

        charsheet.update(avatar_url: @url)
        charsheet.update_message!

        embed = Character::Embed.new_event(event)
        embed.description = "L'avatar de ton personnage a été ajouté à sa feuille !"

        event.channel.send_message('', false, embed)
      end
    end
  end
end
