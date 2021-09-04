module Bot
  module Database
    # Character Model
    class Character < Sequel::Model
      many_to_one :classe, class: '::Bot::Database::Classe'
      #   one_to_many :equipements
      #   one_to_many :wounds

      # Fetches Discord user from bot cache
      def discord_user
        BOT.user(user_discord_id)
      end

      #   def self.find_active(id, channel)
      #     game = Database::Game.where(text_channel_id: channel).first
      #     where(discord_id: id, game_id: game[:id]).first
      #   end

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

      # Generates an embedded charsheet
      def generate_embed(char_id)
        char = Database::Character.search(char_id)

        perso = "Nom ` #{char.char_name} ` \n"\
        "Pronoms : #{char.genre}\n"\
        "Classe : #{char.classe.name}\n"\
        "Apparence : #{char.apparence}\n"\
        "Personnalité : #{char.personnalite}\n"\
        "Histoire : #{char.histoire}"

        stats = "FOR  ` #{char.force} `  "\
        "INT  ` #{char.intelligence} `"\
        "SAG  ` #{char.sagesse} `  "\
        "DEX  ` #{char.dexterite} `  "\
        "CON  ` #{char.constitution} `  "\
        "CHA  ` #{char.charisme} `  \n"\
        "DV ` #{char.classe.dv} ` "\
        "PV Max ` #{char.pv_max} ` "

        embed = Discordrb::Webhooks::Embed.new
        embed.title = 'Fiche Personnage'
        embed.color = 44_783
        embed.description = "Joueur.euse : **#{BOT.user(char.user_discord_id).username}**"
        embed.add_field name: '**Statistiques :** ', value: stats
        embed.add_field name: '**Personnage :** ', value: perso
        # embed.add_field name: '**Blessures :** ', value: wounds.join("\n") unless wounds.empty?
        # embed.add_field name: '**Rumeur :** ', value: char.rumeur
        # embed.add_field name: '**Equipement :** ', value: equipements.join("\n") unless equipements.empty?
        # embed.add_field name: '**Histoires :** ', value: char.histoire unless char.histoire == 'Empty'
        embed
      end
    end
  end
end
