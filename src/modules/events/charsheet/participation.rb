# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Participation
      extend Discordrb::EventContainer

      message(content: /^!pp$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next unless settings

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Voulez-vous ajouter un **Point de Participation** ?\n\n"
        msg += "1 :small_blue_diamond: Oui\n"
        msg += "2 :small_blue_diamond: Non\n\n"

        embed = Character::Embed.char_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > 1
            @pp = nil
            event.channel.message(res.id).delete
            msg = 'Ajout de **PP** annulé.'
            embed = Character::Embed.char_message(charsheet, msg)
            event.channel.send_message('', false, embed)
          else
            @pp = id
          end

          choice.message.delete
          true
        end
        next if @pp.nil?

        event.channel.message(res.id).delete

        char_pp = charsheet.player.participation + 1

        charsheet.player.update(participation: char_pp)
        charsheet.update_message!

        msg = "**Points de Participation (PP)**\n\n"
        msg += "1 point de participation a  été ajouté à ta feuille de personnage\n\n"

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
