# frozen_string_literal: true

module Bot
  module DiscordEvents
    # Feuille de Perso
    module Charsheet
      extend Discordrb::EventContainer

      charsheet = [
        {
          cmd: /^!(c|char|perso){1}(nnage|acter){0,1} (nom|name|fullname){1}([\p{L}\p{M}]*)\s*/i,
          name: 'Nom',
          question: 'Quel est le nom de ton personnage ?',
          min_length: 2,
          error: 'Ton nom est trop court !',
          column: 'char_name'
        },
        {
          cmd: /^!(c|char|perso){1}(nnage|acter){0,1} (pronom|pronoms){1}([\p{L}\p{M}]*)\s*/i,
          name: 'Pronoms',
          question: 'Quels sont les pronoms de ton personnage ?',
          min_length: 1,
          error: 'Pronoms trop courts !',
          column: 'genre'
        },
        {
          cmd: /^!(c|char|perso){1}(nnage|acter){0,1} (align){1}([\p{L}\p{M}]*)\s*/i,
          name: 'Alignement',
          question: "Choisis un alignement : \n"\
          '` Loyal `, ` Neutre ` ou ` Chaotique `',
          min_length: 3,
          error: "Ta réponse est trop courte !\n"\
          "Tu dois répondre par un des mots suivants :\n"\
          '` Loyal `, ` Neutre ` ou ` Chaotique `',
          column: 'alignement'
        }
      ]

      charsheet.each do |c|
        message(start_with: c[:cmd]) do |event|
          args = event.message.content.sub(c[:cmd], '')

          event.message.delete

          settings = Character::Check.all(event)
          next if settings == false

          charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
          next if charsheet.nil?

          if args == c[:cmd] || args.length < c[:min_length]
            msg = (c[:question]).to_s

            embed = Character::Embed.char_message(charsheet, msg)

            res = event.channel.send_message('', false, embed)

            event.user.await!(timeout: 300) do |guess_event|
              if guess_event.message.content.length < c[:min_length]
                guess_event.message.delete
                embed = Character::Embed.char_message(charsheet, c[:error])

                event.channel.send_message('', false, embed)
                false
              else
                @old_content = charsheet[c[:column].to_sym]
                @content = guess_event.message.content
                charsheet.update(c[:column].to_sym => guess_event.message.content)
                guess_event.message.delete

                event.channel.message(res.id).delete
                # msg.delete
                true
              end
            end
          else
            @old_content = charsheet[c[:column].to_sym]
            @content = args
            charsheet.update(c[:column].to_sym => args)
          end
          charsheet.update_message!

          msg = "**#{c[:name]}** modifié :\n"
          msg += "#{@old_content}  :arrow_right:  #{@content}\n\n"
          msg += "*Ta fiche personnage a été mise à jour.*\n\n"

          msg += ":small_blue_diamond: ` !c nom ` Donne un nom à ton personnage.\n" if charsheet.char_name == '!nom'
          if charsheet.genre == '!pronoms'
            msg += ":small_blue_diamond: ` !c pronoms ` Indique quel(s) pronom(s) doivent être utilisés pour ton personnage.\n"
          end
          if charsheet.avatar_url == 'https://i.imgur.com/Q7B91HT.png'
            msg += ':small_blue_diamond: ` !c avatar ` Ajoute un portrait à ton personnage.'
          end

          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
        end
      end
    end
  end
end
