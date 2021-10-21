# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Participation
      extend Discordrb::EventContainer

      message(start_with: '!pp') do |event|
        args = event.message.content.sub(/^!pp\s*/, '')
        event.message.delete

        settings = Character::Check.all(event)
        next unless settings

        if event.user.owner?
          players = Database::Player.all

          msg = 'A quel.le joueur.euse souhaites-tu '
          msg += args == 'remove' ? 'retirer' : 'ajouter'
          msg += " un **Point de Participation** ?\n\n"

          players.each.with_index(1) do |p, index|
            msg += "#{index} :small_blue_diamond: #{BOT.user(p.user_discord_id).username}\n"
          end

          footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

          embed = Character::Embed.event_message(event, msg, footer)

          res = event.channel.send_message('', false, embed)

          event.user.await!(timeout: 300) do |choice|
            id = choice.message.content.to_i
            if id.zero? || id > players.length + 1
              @pp = nil
              event.channel.message(res.id).delete
              msg = 'Ajout de **PP** annulé.'
              embed = Character::Embed.event_message(event, msg)
              event.channel.send_message('', false, embed)
            else
              @pp = id
            end

            choice.message.delete
            true
          end
          next if @pp.nil?

          event.channel.message(res.id).delete

          player = players[@pp - 1]

          char_pp = args == 'remove' ? player.participation - 1 : player.participation + 1

          player.update(participation: char_pp)

          charsheet = Database::Character.find_sheet(player.user_discord_id, event.server.id)
          charsheet.update_message!

          msg = "**Points de Participation (PP)**\n\n"
          msg += '1 point de participation a été '
          msg += args == 'remove' ? 'retiré' : 'ajouté'
          msg += " à #{BOT.user(player.user_discord_id).username}\n\n"

          embed = Character::Embed.event_message(event, msg)

          event.channel.send_message('', false, embed)

          next
        end

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
