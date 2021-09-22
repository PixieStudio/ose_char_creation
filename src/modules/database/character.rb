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
        where(user_discord_id: id).where(server_id: server_id).where(death: false).order(:id).reverse.first
      end

      def self.search(id)
        where(id: id).first
      end

      def sheet_channel
        settings = Database::Settings.find(server_id: server_id)

        BOT.channel(settings.sheet_channel_id)
      end

      def graveyard_channel
        settings = Database::Settings.find(server_id: server_id)

        BOT.channel(settings.graveyard_channel_id)
      end

      def message
        sheet_channel.message(message_id)
      end

      def update_message!
        message.edit('', generate_embed(id))
      end

      def kill_char!
        message.delete
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

      def stats
        "FOR  ` #{force} `  "\
        "INT  ` #{intelligence} `"\
        "SAG  ` #{sagesse} `  "\
        "DEX  ` #{dexterite} `  "\
        "CON  ` #{constitution} `  "\
        "CHA  ` #{charisme} `  "
      end

      def progression
        classe_key = classe.cle
        file = "#{Dir.pwd}/data/progression/#{classe_key}.csv"
        CSV.parse(File.read(file))
      end

      def actual_lvl
        keys = progression[0]
        values = progression[level]
        Hash[keys.zip(values)]
      end

      def next_lvl
        keys = progression[0]
        values = progression[level + 1]
        Hash[keys.zip(values)]
      end

      def previous_lvl
        keys = progression[0]
        values = progression[level - 1]
        Hash[keys.zip(values)]
      end

      def exp_remain
        next_lvl['XP'].to_i - exp
      end

      def carmor
        regex = /^\d*\[(?<ca>\+*\d*)\]/
        actual_lvl['TAC0'].match(regex)['ca']
      end

      def dv
        actual_lvl['DV']
      end

      def saves
        "MP ` #{actual_lvl['MP']} ` "\
        "B ` #{actual_lvl['B']} ` "\
        "PP ` #{actual_lvl['PP']} ` "\
        "S ` #{actual_lvl['S']} ` "\
        "SSB ` #{actual_lvl['SSB']} `"\
      end

      def stuff
        str = ":crossed_swords: Armes ` #{classe.weapon} ` \n"\
        ":shield: Armures ` #{classe.armors} ` \n"\

        str += ":scroll: Sorts ` #{classe.spells} ` " if classe.spells != 'empty'
        str
      end

      def lang
        str = classe.languages
        return str if languages == ''

        char_lang = languages.split(', ')
        char_lang.each do |l|
          str += ", #{l}"
        end
        str
      end

      def rumor
        rumeur.split('|').join("\n")
      end

      def generate_embed(char_id)
        char = Database::Character.search(char_id)

        embed = Bot::Character::Embed.create_sheet(char, stats, saves, stuff, lang, rumor)
        embed
      end

      def mod_att?(value)
        mod_exp = 0
        column = "exp#{value}".to_sym

        classe[column].split(';').each do |c|
          next unless mod_exp.zero?

          /^(?<first_att>[a-z]+)(?<first_value>\d{2})(?<compare_or>\|{2})*(?<compare_and>\&{2})*(?<second_att>[a-z]+)*(?<second_value>\d{2})*$/i =~ c

          if !compare_or.nil?
            if self[first_att.to_sym] >= first_value.to_i || self[second_att.to_sym] >= second_value.to_i
              mod_exp = value
            end
          elsif !compare_and.nil?
            if self[first_att.to_sym] >= first_value.to_i && self[second_att.to_sym] >= second_value.to_i
              mod_exp = value
            end
          elsif self[first_att.to_sym] >= first_value.to_i
            mod_exp = value
          end
        end

        mod_exp
      end
    end
  end
end
