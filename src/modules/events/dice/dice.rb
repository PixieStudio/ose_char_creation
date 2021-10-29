# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Feuille de Perso
    module Charsheet
      extend Discordrb::EventContainer
      @dice_reg = /!(?<number>\d{1,3})d(?<dice>\d{1,3})(?<mod>[+-]?\d{0,3})/i
      message(start_with: @dice_reg) do |event|
        msg = event.message.content
        user = event.user.nickname || event.user.username
        number = msg.match(@dice_reg)[:number].to_i
        dice = msg.match(@dice_reg)[:dice].to_i
        mod = msg.match(@dice_reg)[:mod].to_i
        roll_dice = []
        number.times do
          roll_dice << rand(1..dice)
        end
        sumdice = roll_dice.sum + mod

        # Respond message
        res_msg = []
        res_msg << ":game_die: Dés : #{roll_dice}"
        res_msg << "\n:rocket: Modificateur : #{'+' if mod.positive?}#{mod}" unless mod.zero?
        res_msg << "\n:diamond_shape_with_a_dot_inside: Résultat : #{sumdice}\n"

        event.message.delete

        embed = Character::Embed.event_message(event, res_msg.join("\n"))
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(
          name: "#{event.user.nickname || event.user.username} lance #{number}d#{dice}#{mod unless mod.zero?}",
          icon_url: event.user.avatar_url
        )
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://i.imgur.com/bHs5FGB.png')

        event.channel.send_message('', false, embed) and next
      end
    end
  end
end
