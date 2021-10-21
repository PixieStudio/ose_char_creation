# frozen_string_literal: true

module Bot
  module Database
    # Character Model
    class Player < Sequel::Model
      one_to_many :characters, class: '::Bot::Database::Characters'

      def active_charsheet
        Database::Character.find_by user_discord_id: user_discord_id, selected: true
      end

      def discord_user
        BOT.user(user_discord_id).username
      end
    end
  end
end
