# frozen_string_literal: true

module Bot
  module Character
    # Embed module
    module Embed
      def self.new_event(event)
        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(
          name: (event.user.nickname || event.user.username).to_s,
          icon_url: event.user.avatar_url
        )
        embed.timestamp = Time.now
        embed
      end

      def self.new_sheet(char)
        embed = Discordrb::Webhooks::Embed.new
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(
          name: "#{BOT.user(char.user_discord_id).username} - Feuille de Personnage",
          icon_url: BOT.user(char.user_discord_id).avatar_url
        )
        embed.color = '#9932CC'
        embed.footer = footer_char
        embed.timestamp = Time.now
        embed
      end

      def self.new_merchant(char)
        embed = Discordrb::Webhooks::Embed.new
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(
          name: "#{BOT.user(char.user_discord_id).username} - Commerce",
          icon_url: BOT.user(char.user_discord_id).avatar_url
        )
        embed.color = '#9932CC'
        embed.timestamp = Time.now
        embed
      end

      def self.create_sheet(char, stats, saves, stuff, lang, rumor)
        embed = new_sheet(char)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: char.avatar_url)
        embed.description = ":headstone: **Mort.e :** #{char.death_reason}" if char.death
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Nom**', value: char.char_name, inline: true
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Pronoms**', value: char.genre, inline: true
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Classe**', value: char.classe.name, inline: true
        embed.add_field name: ':shield: **CA**', value: char.carmor, inline: true
        embed.add_field name: ':game_die: **DV**', value: char.dv, inline: true
        embed.add_field name: ':heart: **PV Max**', value: char.pv_max, inline: true
        embed.add_field name: ':star: **Niveau**', value: char.level, inline: true
        embed.add_field name: ':ballot_box_with_check: **EXP**', value: char.exp, inline: true
        embed.add_field name: ':arrow_right: **Niv. Suiv.**', value: char.exp_remain, inline: true
        embed.add_field name: ':trident: **Alignement**', value: char.alignement, inline: true
        embed.add_field name: ":moneybag: **Pièces d'or**", value: char.gold, inline: true
        embed.add_field name: ':compass: **PP**', value: char.player.participation, inline: true
        embed.add_field name: ':dna: **Caractéristiques** ', value: stats
        embed.add_field name: ':revolving_hearts: **Sauvegardes** ', value: saves
        embed.add_field name: '**Equipement et Sorts** ', value: stuff
        embed.add_field name: ':speaking_head: **Langues connues**', value: lang
        embed.add_field name: ':ear: **Rumeur**', value: rumor

        embed
      end

      def self.cancel
        Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')
      end

      def self.footer_char
        Discordrb::Webhooks::EmbedFooter.new(text: '💡 Tape !help si tu es perdu.e.')
      end

      def self.event_message(event, msg, footer = nil)
        embed = new_event(event)
        embed.description = msg
        embed.footer = footer if footer
        embed
      end

      def self.char_message(char, msg)
        embed = new_sheet(char)
        embed.description = msg
        embed
      end

      def self.merchant_message(char, msg, footer = nil)
        embed = new_merchant(char)
        embed.description = msg
        embed.footer = footer.nil? ? Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour quitter') : footer
        embed
      end

      def self.help_message(event, msg)
        settings = Character::Check.settings(event)
        manage_cmd = {
          ":convenience_store:\u0009 !marchands": "Achète chez les #{BOT.channel(settings.merchants_channel_id).mention}",
          ":coin:\u0009 !richesses": "Modifie le montant de tes Pièces d'Or",
          ":compass:\u0009 !pp": 'Ajoute 1 Point de Participation (lié au joueur)',
          ":star2:\u0009 !exp": "Ton personnage gagne de l'expérience",
          ":headstone:\u0009 !mort": 'Envoie ton personnage au cimetière',
          # "\u200B ": "\u200B",
          "\u200B": "\u200B"
        }

        embed = new_event(event)
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: 'https://i.imgur.com/71mgY85.png')
        embed.title = "A l'aide !"
        embed.description = msg.empty? ? '' : ":diamond_shape_with_a_dot_inside:\u0009 #{msg}\n\n"
        embed.description += '__AUTRES COMMANDES__'
        manage_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end
        embed.footer = footer_char
        # embed
        event.channel.send_message('', false, embed)
      end
    end
  end
end
