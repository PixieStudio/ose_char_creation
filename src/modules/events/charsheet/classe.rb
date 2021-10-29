# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Classe
      extend Discordrb::EventContainer

      message(start_with: /^!(c|char|perso){1}(nnage|acter){0,1} (class){1}/i) do |event|
        event.message.delete

        settings = Character::Check.all(event)
        next if settings == false

        charsheet = Database::Character.find_sheet(event.user.id, event.server.id)
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

        msg = "#{best_msg}\n\n"
        msg += "__Classes accessibles__\n\n"
        classes.each.with_index(1) do |c, index|
          main_att = c[:main_attributes].split('|').join(' ')
          msg += "#{index} :small_orange_diamond: #{c[:name]} :small_blue_diamond: #{main_att}\n"
          msg += "*#{c[:page]}*\n\n"
        end
        msg += '*Tape le numéro correspondant à la classe désirée ou `0` pour annuler.*'

        embed = Character::Embed.char_message(charsheet, msg)

        res = event.channel.send_message('', false, embed)

        event.user.await!(timeout: 3000) do |choice|
          id = choice.message.content.to_i

          @classe = if id.zero?
                      nil
                    else
                      classes[id - 1]
                    end

          choice.message.delete
          true
        end
        if @classe.nil?
          event.channel.message(res.id).delete
          msg = "Aucune classe ne correspond à ce chiffre ou temps écoulé.\n\n"
          msg += 'Tape `!classes` à nouveau.'
          embed = Character::Embed.char_message(charsheet, msg)

          event.channel.send_message('', false, embed)
          next
        end

        charsheet.update(classe: @classe)
        charsheet.update_message!
        event.channel.message(res.id).delete

        msg = "\nTu as choisis la classe **#{@classe.name}**.\n\n"
        msg += "*Ta fiche a été mise à jour*\n\n"
        msg += ':small_blue_diamond: `!c ajuster` pour ajuster tes caractéristiques'

        embed = Character::Embed.char_message(charsheet, msg)

        event.channel.send_message('', false, embed)
      end
    end
  end
end
