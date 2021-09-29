# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module SelectChar
      extend Discordrb::EventContainer

      message(content: /^!persos|!perso$/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        chars = Database::Character.char_owned(event.user.id, event.server.id)
        next if chars.length.zero?

        msg = "__LISTE DE TES PERSONNAGES__\n\n"

        chars.each.with_index(1) do |c, index|
          msg += "#{index} :small_blue_diamond: **#{c.char_name}** [#{c.classe.name}]\n"
        end

        embed = Character::Embed.event_message(event, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i
          if id.zero? || id > chars.length
            @selected = nil
            event.channel.message(res.id).delete
            msg = 'Sélection de personnage annulée.'
            embed = Character::Embed.event_message(event, msg)
            event.channel.send_message('', false, embed)
          else
            @selected = chars[id - 1]
          end

          choice.message.delete
          true
        end
        next if @selected.nil?

        event.channel.message(res.id).delete

        Database::Character.select_char(@selected.id, event.user.id, event.server.id)

        msg = "Ton personnage actif est : #{@selected.char_name} [#{@selected.classe.name}]"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
