# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Merchant
      extend Discordrb::EventContainer

      message(content: /^!marchands$/) do |event|
        event.message.delete

        settings = Character::Check.merchants?(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        merchants = Database::Merchant.order(:rank).all

        msg = "Tu possèdes **#{charsheet.gold} PO**\n"
        msg += "*Tapez le numéro correspondant au marchand. `0` pour quitter.*\n\n"
        msg += "__LISTE DES MARCHANDS__\n\n"
        merchants.each.with_index(1) do |m, index|
          msg += "#{index} :small_blue_diamond: #{m[:name]}\n"
        end

        embed = Character::Embed.char_message(charsheet, msg)

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
            msg = event.respond ':small_orange_diamond: Vous quittez le marché.'
          end
          choice.message.delete
          true
        end
        next if @merchant.nil?

        event.channel.message(res.id).delete

        items = @merchant.merchants_items

        msg = "Tu possèdes **#{charsheet.gold} PO**\n"
        msg += "*Tapez le numéro correspondant à l'objet. `0` pour quitter.*\n\n"
        msg += "__ÉTAL DU MARCHAND #{@merchant.name.upcase}__\n\n"
        msg += "1 :small_blue_diamond: Achat libre - Le nom et le prix vous seront demandés.\n\n"
        items.each.with_index(2) do |item, index|
          msg += "#{index} :small_blue_diamond: [#{item.price} PO]"
          msg += " [Poids : #{item.weight}]" if item.weight.positive?
          msg += " #{item.name}\n\n"
        end

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @item = if id.zero?
                    nil
                  else
                    items[id - 2]
                  end

          if @item.nil?
            event.channel.message(res.id).delete
            msg = event.respond ':small_orange_diamond: Vous quittez le marché.'
          end
          choice.message.delete
          true
        end
        next if @item.nil?

        event.channel.message(res.id).delete

        if @item.price > charsheet.gold
          event.respond ":small_orange_diamond: Vous n'avez pas assez d'or et quittez le marché !"
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

        embed = Character::Embed.char_message(charsheet, msg)
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '!marchands pour faire un nouvel achat')

        event.channel.send_message('', false, embed)
      end
    end
  end
end
