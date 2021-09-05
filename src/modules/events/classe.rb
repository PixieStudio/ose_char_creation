module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Classe
      extend Discordrb::EventContainer

      message(content: /^!classes$/) do |event|
        event.message.delete

        settings = Database::Settings.where(server_id: event.server.id)&.first
        unless event.channel.id == settings.creation_channel_id
          msg = "L'édition de ton personnage doit être réalisée dans le salon "\
          "#{BOT.channel(settings.creation_channel_id).mention}"

          event.respond msg
          next
        end

        charsheet = Database::Character.find_sheet(event.user.id)
        next if charsheet.nil?

        attributes_pattern = {
          force: 'FOR',
          intelligence: 'INT',
          dexterite: 'DEX',
          sagesse: 'SAG',
          constitution: 'CON',
          charisme: 'CHA'
        }
        attributes = {}

        attributes_pattern.keys.each do |k|
          attributes[k.to_sym] = charsheet[k.to_sym]
        end
        best = attributes.sort_by { |_k, v| v }.reverse.first(2)

        best_msg = 'Tes deux meilleures caractéristiques sont : '\
        "**#{best[0][0]} (#{best[0][1]})** et **#{best[1][0]} (#{best[1][1]})**"

        classes = Database::Classe.where(Sequel.~(cle: /^base/))\
                                  .where { (force <= charsheet[:force]) }\
                                  .where { (intelligence <= charsheet[:intelligence]) }\
                                  .where { (sagesse <= charsheet[:sagesse]) }\
                                  .where { (dexterite <= charsheet[:dexterite]) }\
                                  .where { (constitution <= charsheet[:constitution]) }\
                                  .where { (charisme <= charsheet[:charisme]) }\
                                  .order(:main_attributes)\
                                  .all

        msg = event.user.mention
        msg += "\n#{best_msg}\n"
        msg += "```md\n"
        msg += "Classes accessibles\n"
        msg += "------\n"
        classes.each.with_index(1) do |c, index|
          main_att = c[:main_attributes].split('|').join(' ')
          msg += "#{index}. #{c[:name]} : #{main_att}\n"
          msg += "*#{c[:page]}*\n\n"
        end
        msg += '```'

        res = event.respond msg

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @classe = if id.zero?
                      nil
                    else
                      classes[id - 1]
                    end

          if @classe.nil?
            msg = event.respond 'Aucune classe ne correspond à ce chiffre. Tape `!classes` à nouveau.'
          else
            choice.message.delete
          end
          true
        end
        next if @classe.nil?

        charsheet.update(classe: @classe)
        charsheet.update_message!
        res.delete

        msg = event.user.mention
        msg += "\nTu as choisis la classe **#{@classe.name}**. Ta fiche a été mise à jour\n"
        msg += "Tu peux ajuster tes caractéristiques à l'aide de la commande `!ajuster`"

        event.respond msg
      end
    end
  end
end
