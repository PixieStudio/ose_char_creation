module Bot
  module DiscordCommands
    module Hello
      extend Discordrb::Commands::CommandContainer
      command :hello do |event|
        'Hello ' + event.user.username
      end

      command :tutorial do |event|
        tutorial = event.send_message CONFIG.tutorial.join("\n")
        tutorial.pin
      end
    end
  end
end
