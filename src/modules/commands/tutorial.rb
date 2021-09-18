# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Show Tutorial
    module Tutorial
      extend Discordrb::Commands::CommandContainer
      command :tutorial do |event|
        event.send_message CONFIG.tutorial.join("\n")
      end
    end
  end
end
