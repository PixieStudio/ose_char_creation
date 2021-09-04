module Bot
  module Database
    # Character Model
    class Character < Sequel::Model
      many_to_one :classe, class: '::Bot::Database::Classe'

      # Fetches Discord user from bot cache
      def discord_user
        BOT.user(user_discord_id)
      end

      def self.find_sheet(id)
        where(user_discord_id: id).order(:id).reverse.first
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

      # Generates an embedded charsheet
      def generate_embed(char_id)
        char = Database::Character.search(char_id)

        perso = "Nom ` #{char.char_name} ` \n"\
        "Pronoms : ` #{char.genre} ` \n"\
        "Classe : ` #{char.classe.name} ` \n"\
        "Rumeur : ` A définir ` \n"\
        "Apparence : #{char.apparence}\n"\
        "Personnalité : #{char.personnalite}\n"\
        "Histoire : #{char.histoire}"

        stats = "FOR  ` #{char.force} `  "\
        "INT  ` #{char.intelligence} `"\
        "SAG  ` #{char.sagesse} `  "\
        "DEX  ` #{char.dexterite} `  "\
        "CON  ` #{char.constitution} `  "\
        "CHA  ` #{char.charisme} `  \n"

        sante = "DV ` #{char.classe.dv} ` "\
        "PV Max ` #{char.pv_max} ` "

        embed = Discordrb::Webhooks::Embed.new
        embed.title = 'Fiche Personnage'
        embed.color = 44_783
        embed.description = "Joueur.euse : **#{BOT.user(char.user_discord_id).username}**"
        embed.add_field name: '**Statistiques :** ', value: stats
        embed.add_field name: '**Santé :** ', value: sante
        embed.add_field name: '**Personnage :** ', value: perso
        embed
      end
    end
  end
end
