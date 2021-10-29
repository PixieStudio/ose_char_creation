# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Merchant
      extend Discordrb::EventContainer

      message(start_with: /^!(marchan|mercant){1}/) do |event|
        event.message.delete

        settings = Character::Check.merchants?(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        merchants = Database::Merchant.order(:rank).all

        msg = "Tu possèdes **#{charsheet.gold} PO**\n"
        msg += "*Tape le numéro correspondant au marchand.*\n\n"
        msg += "__LISTE DES MARCHANDS__\n\n"
        merchants.each.with_index(1) do |m, index|
          msg += "#{index} :small_blue_diamond: #{m[:name]}\n"
        end

        embed = Character::Embed.merchant_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @merchant = if id.zero?
                        nil
                      else
                        merchants[id - 1]
                      end

          if @merchant.nil?
            event.channel.message(res.id).delete
            msg = event.respond ":small_orange_diamond: #{event.user.nickname || event.user.username} quitte le marché."
          end
          choice.message.delete
          true
        end
        next if @merchant.nil?

        event.channel.message(res.id).delete

        items = @merchant.merchants_items

        msg = "Tu possèdes **#{charsheet.gold} PO**\n"
        msg += "*Tape le numéro correspondant à l'objet. `0` pour quitter.*\n\n"
        msg += "__ÉTAL DU MARCHAND #{@merchant.name.upcase}__\n\n"
        msg += "1 :small_blue_diamond: Achat libre - Le nom et le prix vous seront demandés.\n\n"
        items.each.with_index(2) do |item, index|
          msg += "#{index} :small_blue_diamond: [#{item.price} PO]"
          msg += " [Poids : #{item.weight}]" if item.weight.positive?
          msg += " #{item.name}\n\n"
        end

        embed = Character::Embed.merchant_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @item = if id.zero?
                    nil
                  elsif id == 1
                    @item = 1000
                  else
                    items[id - 2]
                  end

          if @item.nil?
            event.channel.message(res.id).delete
            msg = event.respond ":small_orange_diamond: #{event.user.nickname || event.user.username} quitte le marché."
          end
          choice.message.delete
          true
        end
        next if @item.nil?

        event.channel.message(res.id).delete

        if @item == 1000
          @item = OpenStruct.new

          msg = "Quel est le **NOM** de l'objet que tu souhaites acheter ?\n\n"

          embed = Character::Embed.merchant_message(charsheet, msg)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Répond avec le nom uniquement')

          res = event.channel.send_message('', false, embed)

          event.user.await!(timeout: 300) do |choice|
            @item.name = choice.message.content

            choice.message.delete
            true
          end

          event.channel.message(res.id).delete

          msg = "Quel est le **PRIX** de l'objet que tu souhaites acheter ?\n\n"

          embed = Character::Embed.merchant_message(charsheet, msg)
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Répond avec des chiffres uniquement.')
          res = event.channel.send_message('', false, embed)

          event.user.await!(timeout: 300) do |choice|
            @item.price = choice.message.content.to_i

            choice.message.delete
            true
          end

        end

        if @item.price > charsheet.gold
          event.respond ":small_orange_diamond: #{event.user.nickname || event.user.username} n'a pas assez d'or et quitte le marché !"
          next
        end

        old_gold = charsheet.gold
        new_gold = charsheet.gold - @item.price
        charsheet.update(gold: new_gold)
        charsheet.update_message!

        msg = "Tu possédais **#{old_gold} PO** et tu as acheté :\n"\
        "**#{@item.name.gsub(/\n\*.*$/i, '')}** pour **#{@item.price} PO** "\
        "chez le marchand **#{@merchant.name}**.\n\n"\
        "Il te reste **#{charsheet.gold} PO**."

        embed = Character::Embed.merchant_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '!marchands pour faire un nouvel achat')

        event.channel.send_message('', false, embed)
      end
    end
  end
end
