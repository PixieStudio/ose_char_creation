# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module LevelUp
      extend Discordrb::EventContainer

      message(content: /^!level up$/) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Ton personnage progresse d'un niveau ?\n\n"
        msg += "1 :small_blue_diamond: Oui\n"
        msg += "2 :small_blue_diamond: Non\n\n"

        embed = Character::Embed.char_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > 1
            @levelup = nil
            event.channel.message(res.id).delete
            msg = 'Montée de niveau annulée.'
            embed = Character::Embed.char_message(charsheet, msg)
            event.channel.send_message('', false, embed)
          else
            @levelup = id
          end

          choice.message.delete
          true
        end
        next if @levelup.nil?

        event.channel.message(res.id).delete

        # PV
        # Sauvegarde

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
