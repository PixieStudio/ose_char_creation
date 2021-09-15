# frozen_string_literal: true

module Bot
  module Character
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
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: char.avatar_url)
        embed.timestamp = Time.now
        embed
      end

      def self.create_sheet(char, stats, saves, stuff)
        embed = new_sheet(char)
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Nom**', value: char.char_name, inline: true
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Pronoms**', value: char.genre, inline: true
        embed.add_field name: ':diamond_shape_with_a_dot_inside: **Classe**', value: char.classe.name, inline: true
        embed.add_field name: ':trident: **Alignement**', value: char.alignement, inline: true
        embed.add_field name: ':game_die: **DV**', value: char.classe.dv, inline: true
        embed.add_field name: ':heart: **PV Max**', value: char.pv_max, inline: true
        embed.add_field name: ':star: **Niv. max.**', value: char.classe.max_lvl, inline: true
        embed.add_field name: ":moneybag: **Pièces d'or**", value: char.gold, inline: true
        embed.add_field name: ':compass: **PP**', value: char.participation, inline: true
        embed.add_field name: ':dna: **Caractéristiques** ', value: stats
        embed.add_field name: ':revolving_hearts: **Sauvegardes** ', value: saves
        embed.add_field name: '**Equipement et Sorts** ', value: stuff
        embed.add_field name: ':speaking_head: **Langues connues**', value: char.classe.languages
        embed.add_field name: ':ear: **Rumeur**', value: char.rumeur
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '💡 Tape !commande pour modifier ta feuille.')

        embed
      end

      def self.cancel
        Discordrb::Webhooks::EmbedFooter.new(text: 'Tape 0 pour annuler.')
      end
    end
  end
end
