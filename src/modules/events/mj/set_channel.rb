# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module SetChannels
      extend Discordrb::EventContainer

      options = [
        {
          cmd: 'creation',
          title: 'Choix du salon de création de personnage',
          question: ':pen_ballpoint: Dans quel salon les joueurs doivent-ils créer leur personnage ?',
          result: 'Salon de création de personnage : ',
          column: 'creation_channel_id'
        },
        {
          cmd: 'charsheet',
          title: 'Choix du salon de publication de feuille personnage',
          question: ':bookmark: Dans quel salon les fiches doivent-elles être publiées ?',
          result: 'Salon de publication de feuille de personnage : ',
          column: 'sheet_channel_id'
        },
        {
          cmd: 'merchants',
          title: 'Choix du salon des marchands',
          question: ':moneybag: Quel salon est réservé au commerce ?',
          result: 'Salon des marchands : ',
          column: 'merchants_channel_id'
        }

      ]

      options.each do |option|
        message(content: /^!set channel #{option[:cmd]}.*$/i) do |event|
          event.message.delete

          next unless event.user.owner?

          channels = event.server.text_channels

          msg = "#{option[:question]}\n\n"
          channels.each.with_index(1) do |c, index|
            msg += "#{index} :small_blue_diamond: #{c.name}\n"
          end
          msg += "\n*Veuillez taper le numéro correspondant au salon ou `0` pour annuler.*"

          embed = Character::Embed.event_message(event, msg)
          embed.title = option[:title]

          res = event.channel.send_message('', false, embed)

          event.user.await!(timeout: 300) do |choice|
            event.channel.message(res.id).delete

            id = choice.message.content.to_i

            @channel = if id.zero?
                         nil
                       else
                         channels[id - 1].id
                       end

            choice.message.delete
            true
          end

          if @channel.nil?
            msg = "Opération annulée.\n\n"
            msg += '`!settings` Affiche les commandes de configuration. '

            embed = Character::Embed.event_message(event, msg)
            embed.title = option[:title]

            event.channel.send_message('', false, embed)
            next
          end

          server_id = event.server.id

          server = Database::Settings.find(server_id: server_id)
          if server.nil?
            Database::Settings.create(
              server_id: server_id,
              option[:column] => @channel
            )

          else
            server.update(option[:column] => @channel)
          end

          msg = option[:result]
          msg += "#{BOT.channel(@channel).mention}\n"

          embed = Character::Embed.event_message(event, msg)

          event.channel.send_message('', false, embed)
        end
      end
    end
  end
end
