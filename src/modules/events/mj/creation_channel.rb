# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module CreationChannel
      extend Discordrb::EventContainer
      message(content: /^!set creation channel.*$/i) do |event|
        event.message.delete

        next unless event.user.owner?

        channels =  event.server.text_channels

        msg = "**Liste des salons textuels**\n\n"
        channels.each.with_index(1) do |c, index|
          msg += "#{index} :small_blue_diamond: #{c.name}\n"
        end
        msg += "\n*Veuillez taper le numéro correspondant au salon ou `0` pour annuler.*"

        embed = Character::Embed.event_message(event, msg)
        embed.title = ':pen_ballpoint: Dans quel salon les joueurs doivent-ils créer leur fiche ?'

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          event.channel.message(res.id).delete

          id = choice.message.content.to_i

          @creation_channel = if id.zero?
                                nil
                              else
                                channels[id - 1].id
                              end

          choice.message.delete
          true
        end
        if @creation_channel.nil?
          msg = "Opération annulée.\n\n"
          msg += '`!settings` Commandes des paramètres '

          embed = Character::Embed.event_message(event, msg)
          embed.title = 'Choix du salon de création'

          event.channel.send_message('', false, embed)
          next
        end

        server_id = event.server.id

        server = Database::Settings.find(server_id: server_id)
        if server.nil?
          Database::Settings.create(
            server_id: server_id,
            creation_channel_id: @creation_channel
          )

        else
          server.update(creation_channel_id: @creation_channel)
        end

        msg = 'Salon de création de personnage : '
        msg += "#{BOT.channel(@creation_channel).mention}\n"

        embed = Character::Embed.event_message(event, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
