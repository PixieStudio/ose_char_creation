# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Show Tutorial
    module Seed
      extend Discordrb::Commands::CommandContainer
      #   command :seed do |event|
      #     classes = Database::Classe.where(Sequel.~(cle: /^base/)).all
      #     settings = Bot::Character::Check.settings(event)

      #     classes.each do |c|
      #       puts c.id

      #       new_player = Database::Character.create(
      #         user_discord_id: event.user.id,
      #         server_id: event.server.id,
      #         classe: c,
      #         force: 13,
      #         dexterite: 13,
      #         sagesse: 13,
      #         intelligence: 13,
      #         constitution: 13,
      #         charisme: 13,
      #         pv_max: 6,
      #         gold: 100
      #       )
      #       fiche = BOT.channel(settings.sheet_channel_id)
      #       fiche_msg = fiche.send_message('', false, new_player.generate_embed(new_player[:id]))

      #       new_player.update(message_id: fiche_msg.id)

      #       sleep 2
      #     end
      #     puts 'finished'
      #   end

      #   command :upstat do |_event|
      #     charsheet = Database::Character.order(Sequel.desc(:id)).limit(38)
      #     charsheet.each do |c|
      #       puts c.id
      #       c.update(force: 17, intelligence: 17, sagesse: 17, dexterite: 17, constitution: 17, charisme: 17)
      #     end
      #     puts 'finished'
      #   end

      #   command :lvlup do |_event|
      #     charsheet = Database::Character.order(Sequel.desc(:id)).limit(38)
      #     charsheet.each do |c|
      #       mod_exp = c.mod_att?(10)
      #       mod_exp = c.mod_att?(5) if mod_exp.zero?
      #       puts mod_exp if c.id == 79
      #     end
      #     puts 'finished'
      #   end
      #   command :kinesiste do |event|
      #     classe = Database::Classe.where(cle: 'kinesiste').first
      #     settings = Bot::Character::Check.settings(event)

      #     new_player = Database::Character.create(
      #       user_discord_id: event.user.id,
      #       server_id: event.server.id,
      #       classe: classe,
      #       force: 13,
      #       dexterite: 13,
      #       sagesse: 13,
      #       intelligence: 13,
      #       constitution: 13,
      #       charisme: 13
      #     )
      #     fiche = BOT.channel(settings.sheet_channel_id)
      #     fiche_msg = fiche.send_message('', false, new_player.generate_embed(new_player[:id]))

      #     new_player.update(message_id: fiche_msg.id)
      #   end
    end
  end
end
