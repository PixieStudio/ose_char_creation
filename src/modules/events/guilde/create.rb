# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Create Guild
    module GuildCreate
      extend Discordrb::EventContainer

      message(start_with: /^!(g|guild|guilde){1} (new|créer|creer|create){1}/i) do |event|
        settings = Character::Check.all(event)
        next if settings == false

        /^!(g|guild|guilde){1} (new|créer|creer|create){1} (?<guild_name>.+)/i =~ event.message.content

        msg = '`!g new [nom de la guilde]` pour valider la création.'
        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed) and next if guild_name.nil?

        # event.respond msg and next if guild_name.nil?

        Database::Guild.create(
          server_id: event.server.id,
          name: guild_name
        )

        msg = "La guilde **#{guild_name}** a été créée. Vous pouvez définir ses richesses " \
        '`!g gold [valeur numérique]`'

        event.respond msg and next
      end
    end
  end
end
