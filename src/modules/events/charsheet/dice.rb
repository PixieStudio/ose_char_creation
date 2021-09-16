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
        res_msg << '```md'
        res_msg << "#{user} lance #{number}d#{dice}#{mod unless mod.zero?}"
        res_msg << '------------'
        res_msg << "Dés : #{roll_dice}"
        res_msg << "Modificateur : #{mod}" unless mod.zero?
        res_msg << "Résultat : #{sumdice}"
        res_msg << '```'

        event.message.delete
        event.respond res_msg.join("\n")
      end
    end
  end
end
