module Bot
  module Database
    # Character Model
    class Character < Sequel::Model
      many_to_one :classe, class: '::Bot::Database::Classe'

      # Fetches Discord user from bot cache
      def discord_user
        BOT.user(user_discord_id)
      end

      def self.find_sheet(id, server_id)
        where(user_discord_id: id).where(server_id: server_id).order(:id).reverse.first
      end

      def self.search(id)
        where(id: id).first
      end

      def sheet_channel
        settings = Database::Settings.find(server_id: server_id)

        BOT.channel(settings.sheet_channel_id)
      end

      def message
        sheet_channel.message(message_id)
      end

      def update_message!
        message.edit('', generate_embed(id))
      end

      def const_mod
        if constitution == 3
          -3
        elsif constitution.between?(4, 5)
          -2
        elsif constitution.between?(6, 8)
          -1
        elsif constitution.between?(9, 12)
          0
        elsif constitution.between?(13, 15)
          1
        elsif constitution.between?(16, 17)
          2
        else
          3
        end
      end

      def generate_embed(char_id)
        char = Database::Character.search(char_id)

        stats = "FOR  ` #{char.force} `  "\
        "INT  ` #{char.intelligence} `"\
        "SAG  ` #{char.sagesse} `  "\
        "DEX  ` #{char.dexterite} `  "\
        "CON  ` #{char.constitution} `  "\
        "CHA  ` #{char.charisme} `  "

        saves = "MP ` #{char.classe.save_mp} ` "\
        "B ` #{char.classe.save_b} ` "\
        "PP ` #{char.classe.save_pp} ` "\
        "S ` #{char.classe.save_s} ` "\
        "SSB ` #{char.classe.save_ssb} `"\

        stuff = ":crossed_swords: Armes ` #{char.classe.weapon} ` \n"\
        ":shield: Armures ` #{char.classe.armors} ` \n"\

        stuff += ":scroll: Sorts ` #{char.classe.spells} ` " if char.classe.spells != 'empty'

        embed = Discordrb::Webhooks::Embed.new
        embed.author = Discordrb::Webhooks::EmbedAuthor.new(
          name: "#{BOT.user(char.user_discord_id).username} - Feuille de Personnage",
          icon_url: BOT.user(char.user_discord_id).avatar_url
        )
        embed.color = '#9932CC'
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
        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(
          url: char.avatar_url
        )
        embed.add_field name: ':speaking_head: **Langues connues**', value: char.classe.languages
        embed.add_field name: ':ear: **Rumeur**', value: char.rumeur
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: '💡 Tape !commande pour modifier ta feuille.')
        embed.timestamp = Time.now
        embed
      end
    end
  end
end
