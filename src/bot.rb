# frozen_string_literal: true

# Gems
require 'bundler/setup'
require 'discordrb'
require 'yaml'

# The main bot module.
module Bot
  # Load non-Discordrb modules
  Dir['src/modules/*.rb'].each { |mod| load mod }

  # Characters modules
  Dir['src/modules/character/*.rb'].each { |mod| load mod }

  # Bot configuration
  CONFIG = Config.new

  # Create the bot.
  BOT = Discordrb::Commands::CommandBot.new(client_id: CONFIG.client_id,
                                            token: CONFIG.token,
                                            prefix: CONFIG.prefix,
                                            help_command: false)

  # Discord commands
  module DiscordCommands; end
  Dir['src/modules/commands/*.rb'].each { |mod| load mod }
  DiscordCommands.constants.each do |mod|
    BOT.include! DiscordCommands.const_get mod
  end

  # Discord events
  module DiscordEvents; end
  Dir['src/modules/events/*.rb'].each { |mod| load mod }
  DiscordEvents.constants.each do |mod|
    BOT.include! DiscordEvents.const_get mod
  end

  at_exit { BOT.stop }
  # Run the bot
  BOT.run
end
