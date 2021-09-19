# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Mort
      extend Discordrb::EventContainer

      message(content: /^!mort$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Ton personnage est mort ?\n\n"
        msg += "1 :small_blue_diamond: Oui\n"
        msg += "2 :small_blue_diamond: Non\n\n"

        embed = Character::Embed.char_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > 1
            @death = nil
            event.channel.message(res.id).delete
            msg = 'Mort du personnage annulée.'
            embed = Character::Embed.char_message(charsheet, msg)
            event.channel.send_message('', false, embed)
          else
            @death = id
          end

          choice.message.delete
          true
        end
        next if @death.nil?

        event.channel.message(res.id).delete

        msg = "Comment ton personnage est-il mort ?\n\n"
        msg += '*Répond par une phrase courte de quelques mots.*'

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          @reason = choice.message.content

          choice.message.delete
          true
        end

        event.channel.message(res.id).delete

        charsheet.update(death: true, death_reason: @reason)
        # charsheet.update_message!

        # BOT.channel(settings.sheet_channel_id).message(charsheet.message_id).delete
        charsheet.kill_char!

        graveyard = BOT.channel(settings.graveyard_channel_id)
        graveyard.send_message('', false, charsheet.generate_embed(charsheet.id))

        msg = "Ton personnage a été envoyé au #{graveyard.mention}"

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
