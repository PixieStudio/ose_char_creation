# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Mort
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} (mort|dead|death){1}/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Ton personnage est mort ?\n\n"
        msg += "*Réponds par **oui** pour valider, ou n'importe quoi d'autre pour annuler.*"

        embed = Character::Embed.char_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content
          @death = id.match?(/^(oui|yes)$/i) ? nil : 1

          choice.message.delete
          true
        end

        unless @death.nil?
          event.channel.message(res.id).delete
          msg = 'Mort du personnage annulée.'
          embed = Character::Embed.char_message(charsheet, msg)
          event.channel.send_message('', false, embed)
          next
        end

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
