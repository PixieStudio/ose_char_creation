module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Merchant
      extend Discordrb::EventContainer

      message(content: /^!marchands$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        unless event.channel.id == settings.merchants_channel_id
          msg = "Le commerce s'effecture dans le salon "\
          "#{BOT.channel(settings.merchants_channel_id).mention}"

          event.respond msg
          next
        end

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        merchants = Database::Merchant.order(:rank).all

        msg = "#{event.user.mention} possède **#{charsheet.gold} PO**"
        msg += "```md\n"
        msg += "Liste des Marchands\n"
        msg += "------\n"
        merchants.each.with_index(1) do |m, index|
          msg += "#{index}. #{m[:name]}\n"
        end
        msg += '```'
        msg += '*Tapez le numéro correspondant au marchand. `0` pour quitter.*'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @merchant = if id.zero?
                        nil
                      else
                        merchants[id - 1]
                      end

          if @merchant.nil?
            res.delete
            msg = event.respond '*Vous quittez le marché.*'
          end
          choice.message.delete
          true
        end
        next if @merchant.nil?

        res.delete

        items = @merchant.merchants_items

        msg = "#{event.user.mention} possède **#{charsheet.gold} PO**"
        msg += "```md\n"
        msg += "Étal du marchand : #{@merchant.name}\n"
        msg += "------\n"
        items.each.with_index(1) do |item, index|
          msg += "#{index}. [#{item.price} PO]"
          msg += " [Poids : #{item.weight}]" if item.weight.positive?
          msg += " #{item.name}\n\n"
        end
        msg += '```'
        msg += '*Tapez le numéro correspondant au marchand. `0` pour quitter.*'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @item = if id.zero?
                    nil
                  else
                    items[id - 1]
                  end

          if @item.nil?
            res.delete
            msg = event.respond '*Vous quittez le marché.*'
          end
          choice.message.delete
          true
        end
        next if @item.nil?

        res.delete

        if @item.price > charsheet.gold
          event.respond "Vous n'avez pas assez d'or et quittez le marché !"
          next
        end

        old_gold = charsheet.gold
        new_gold = charsheet.gold - @item.price
        charsheet.update(gold: new_gold)
        charsheet.update_message!

        event.respond "#{event.user.mention} possédait **#{old_gold} PO** et a acheté **#{@item.name.gsub(/\n\*.*$/i, '')}** pour **#{@item.price} PO** chez le marchand **#{@merchant.name}**. Or restant : **#{charsheet.gold} PO**."
      end
    end
  end
end
