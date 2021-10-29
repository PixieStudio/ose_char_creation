# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Language
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} (lang){1}/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
        next if charsheet.nil?

        if charsheet.intelligence < 13
          msg = "L'**intelligence** de ton personnage doit être supérieure à **13** pour apprendre une langue supplémentaire."
          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        languages = Database::Language.all

        learned = charsheet.languages.split(', ').count

        if charsheet.intelligence.between?(13, 15)

          unless learned.zero?
            msg = "L'**intelligence** de ton personnage ne te permet de parler qu'**une** langue supplémentaire."
            embed = Character::Embed.char_message(charsheet, msg)

            event.channel.send_message('', false, embed)
            next
          end

          msg = "Ton personnage peut apprendre **une langue**.\n\n"
        end

        if charsheet.intelligence.between?(16, 17)
          unless learned < 2
            msg = "L'**intelligence** de ton personnage ne te permet de parler que **deux** langues supplémentaires."
            embed = Character::Embed.char_message(charsheet, msg)

            event.channel.send_message('', false, embed)
            next
          end

          msg = "Ton personnage peut apprendre **#{2 - learned} langue(s)**.\n\n"
        end

        if charsheet.intelligence == 18
          unless learned < 3
            msg = "L'**intelligence** de ton personnage ne te permet de parler que **trois** langues supplémentaires."
            embed = Character::Embed.char_message(charsheet, msg)

            event.channel.send_message('', false, embed)
            next
          end

          msg = "Ton personnage peut apprendre **#{3 - learned} langue(s)**.\n\n"
        end

        msg += "__Liste des langues disponibles :__\n"
        languages.each.with_index(1) do |l, index|
          msg += "#{index}. #{l[:name]}\n"
        end
        msg += "\n*Répond avec le numéro de la langue choisie, ou `0` pour annuler*"

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 300) do |choice|
          id = choice.message.content.to_i

          @new_lang = if id.zero?
                        nil
                      else
                        languages[id - 1]
                      end

          if @new_lang.nil?
            msg = 'Aucune langue ne correspond à ce chiffre. Tape `!c langues` à nouveau.'

            embed = Character::Embed.char_message(charsheet, msg)

            event.channel.send_message('', false, embed)
          else
            choice.message.delete
          end
          event.channel.message(res.id).delete
          true
        end
        next if @new_lang.nil?

        lang = charsheet.languages == '' ? '' : "#{charsheet.languages}, "
        lang += @new_lang.name

        charsheet.update(languages: lang)
        charsheet.update_message!

        msg = "\nTon personnage parle une langue supplémentaire\n**#{@new_lang.name}**.\n\n*Ta fiche a été mise à jour*\n"

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
