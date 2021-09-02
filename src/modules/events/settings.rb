module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Settings
      extend Discordrb::EventContainer
      message(content: /^!settings.*$/i) do |event|
        event.message.delete

        channels =  event.server.text_channels

        msg = ':pen_ballpoint: Dans quel salon les joueurs doivent-ils créer leur fiche ? :pen_ballpoint:'
        msg += "```md\n"
        msg += "Liste des salons textuels\n"
        msg += "-------\n"
        channels.each.with_index(1) do |c, index|
          msg += "#{index}. #{c.name}\n"
        end
        msg += '```'
        msg += '*Veuillez taper le numéro correspondant au salon désiré*'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          creation_channel = if id.zero?
                               nil
                             else
                               channels[id - 1].id
                             end

          if creation_channel.nil?
            msg = event.respond "Aucun salon n'a été trouvé."
            sleep 3
            msg.delete
          else
            @creation = creation_channel

            res.delete
            choice.message.delete
            true
          end
        end

        msg = ':bookmark: Dans quel salon les fiches doivent-elles être publiées ? :bookmark:'
        msg += "```md\n"
        msg += "Liste des salons textuels\n"
        msg += "-------\n"
        channels.each.with_index(1) do |c, index|
          msg += "#{index}. #{c.name}\n"
        end
        msg += '```'
        msg += '*Veuillez taper le numéro correspondant au salon désiré*'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          sheet_channel = if id.zero?
                            nil
                          else
                            channels[id - 1].id
                          end

          if sheet_channel.nil?
            msg = event.respond "Aucun salon n'a été trouvé."
            sleep 3
            msg.delete
          else
            @sheet = sheet_channel

            res.delete
            choice.message.delete
            true
          end
        end

        server_id = event.server.id

        server = Database::Settings.find(server_id: server_id)
        if server.nil?
          new_server = Database::Settings.create(
            server_id: server_id,
            creation_channel_id: @creation,
            sheet_channel_id: @sheet
          )

          new_server.save
        else
          server.update(creation_channel_id: @creation,
                        sheet_channel_id: @sheet)
        end

        msg = 'Le salon de création est à présent : '
        msg += "#{BOT.channel(@creation).mention}\n"
        msg += 'Le salon des fiches publiées est à présent : '
        msg += "#{BOT.channel(@sheet).mention}\n"

        event.respond msg
      end
    end
  end
end
