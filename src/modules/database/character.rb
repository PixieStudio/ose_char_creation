# frozen_string_literal: true

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

      def stats(char)
        "FOR  ` #{char.force} `  "\
        "INT  ` #{char.intelligence} `"\
        "SAG  ` #{char.sagesse} `  "\
        "DEX  ` #{char.dexterite} `  "\
        "CON  ` #{char.constitution} `  "\
        "CHA  ` #{char.charisme} `  "
      end

      def saves(char)
        "MP ` #{char.classe.save_mp} ` "\
        "B ` #{char.classe.save_b} ` "\
        "PP ` #{char.classe.save_pp} ` "\
        "S ` #{char.classe.save_s} ` "\
        "SSB ` #{char.classe.save_ssb} `"\
      end

      def stuff(char)
        str = ":crossed_swords: Armes ` #{char.classe.weapon} ` \n"\
        ":shield: Armures ` #{char.classe.armors} ` \n"\

        str += ":scroll: Sorts ` #{char.classe.spells} ` " if char.classe.spells != 'empty'
        str
      end

      def lang(char)
        str = char.classe.languages
        return str if char.languages == ''

        char_lang = char.languages.split(', ')
        char_lang.each do |l|
          str += ", #{l}"
        end
        str
      end

      def generate_embed(char_id)
        char = Database::Character.search(char_id)

        embed = Bot::Character::Embed.create_sheet(char, stats(char), saves(char), stuff(char), lang(char))
        embed
      end
    end
  end
end
