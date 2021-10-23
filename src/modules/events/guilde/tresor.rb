# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Guild Treasure Manager
    module GuildTresor
      extend Discordrb::EventContainer

      message(start_with: /^!(g|guild|guilde){1} (tresor|trésor|treasure|gold){1}/i) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        msg = "Tu ne fais partie d'aucune guilde.\n" \
       '`!g join` pour en rejoindre une.'
        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed) and next if charsheet.guild.nil?

        /^!(g|guild|guilde){1} (tresor|trésor|treasure|gold){1}+s{0,1} (?<action>add|ajouter|ajout|\+|-|remove|retirer){1}\s*(?<amount>\d+)+/i =~ event.message.content

        if amount.nil? || action.nil?
          msg = "Tu dois indiquer une action et un montant\n*Exemple :* `!g tresor ajout 100`"
          embed = Character::Embed.event_message(event, msg)

          event.channel.send_message('', false, embed)
          next
        end

        if action.match?(/(add|ajouter|ajout|\+)/i)
          @gold = charsheet.guild.gold + amount.to_i
          @mod_gold = '+'
        else
          @gold = charsheet.guild.gold - amount.to_i
          @mod_gold = '-'
        end

        @old_gold = charsheet.guild.gold

        charsheet.guild.update(gold: @gold)
        event.message.delete

        msg = "Trésorerie de la guilde **#{charsheet.guild.name}** modifiée : **#{@mod_gold}#{amount} PO**"
        msg += "\n#{@old_gold}  :arrow_right:  #{@gold}\n\n"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
