module Bot
  module DiscordEvents
    # Feuille de Perso
    module Charsheet
      extend Discordrb::EventContainer

      charsheet = [
        {
          cmd: '!nom',
          question: 'Quel est le nom de ton personnage ?',
          min_length: 2,
          error: 'Ton nom est trop court !',
          column: 'char_name'
        },
        {
          cmd: '!pronoms',
          question: 'Quels sont les pronoms de ton personnage ?',
          min_length: 1,
          error: 'Pronoms trop courts !',
          column: 'genre'
        },
        # {
        #   cmd: '!apparence',
        #   question: "A quoi ressemble ton personnage ?\n",
        #   min_length: 3,
        #   error: 'Ton apparence est trop courte !',
        #   column: 'apparence'
        # },
        # {
        #   cmd: '!personnalite',
        #   question: "Quelle est la personnalité de ton personnage ?\n",
        #   min_length: 3,
        #   error: 'Ta personnalite est trop courte !',
        #   column: 'personnalite'
        # },
        # {
        #   cmd: '!histoire',
        #   question: "Raconte-nous l'histoire de ton personnage ! \n"\
        #   '*Max 1500 caractères*',
        #   min_length: 3,
        #   error: 'Ton histoire est trop courte !',
        #   column: 'histoire'
        # },
        {
          cmd: '!alignement',
          question: "Choisis un alignement : \n"\
          '` Loyal `, ` Neutre ` ou ` Chaotique `',
          min_length: 3,
          error: 'Ton histoire est trop courte !',
          column: 'alignement'
        }
      ]

      charsheet.each do |c|
        message(start_with: c[:cmd]) do |event|
          args = event.message.content.sub("#{c[:cmd]} ", '')

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

          if args == c[:cmd] || args.length < c[:min_length]
            msg = event.respond "#{event.user.mention} #{c[:question]}"
            event.user.await!(timeout: 300) do |guess_event|
              if guess_event.message.content.length < c[:min_length]
                guess_event.respond c[:error]
                false
              else
                charsheet.update(c[:column].to_sym => guess_event.message.content)
                guess_event.message.delete
                msg.delete
                true
              end
            end
          else
            charsheet.update(c[:column].to_sym => args)
          end
          charsheet.update_message!

          msg = "#{event.user.mention} *Ta fiche personnage a été mise à jour.*\n\n"
          msg += "Tu peux continuer la personnalisation de ton personnage à l'aide des commandes :\n"
          # msg += '` !nom ` ` !pronoms ` ` !apparence ` ` !personnalite `'
          msg += '` !nom ` ` !pronoms `'

          event.respond msg
        end
      end
    end
  end
end
