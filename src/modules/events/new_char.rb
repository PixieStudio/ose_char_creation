module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module NewChar
      extend Discordrb::EventContainer
      message(content: /^!nouveau perso.*$/i) do |event|
      end
    end
  end
end
