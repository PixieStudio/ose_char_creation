module Bot
  module Database
    # Character Model
    class Character < Sequel::Model
      #   many_to_one :game, class: '::Bot::Database::Game'
      many_to_one :classe, class: '::Bot::Database::Classe'
      #   one_to_many :equipements
      #   one_to_many :wounds

      # Fetches Discord user from bot cache
      def discord_user
        BOT.user(discord_id)
      end

      #   def self.find_active(id, channel)
      #     game = Database::Game.where(text_channel_id: channel).first
      #     where(discord_id: id, game_id: game[:id]).first
      #   end

      #   def self.find_sheet(id, channel)
      #     where(discord_id: id, text_channel_id: channel).first
      #   end

      def self.search(id)
        where(id: id).first
      end

      def text_channel
        BOT.channel(text_channel_id)
      end

      def message
        text_channel.message(fiche_msg_id)
      end

      def update_message!
        message.edit('', generate_embed(id))
      end

      # Generates an embedded charsheet
      def generate_embed(char_id)
        char = Database::Character.search(char_id)
        # livret = char.livret

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
        "CHA  ` #{char.charisme} `  "

        # wounds = "Première blessure : #{char.first_wound}\n"\
        # "Seconde blessure : #{char.second_wound}"

        # equipements = []
        # char.equipements.each do |e|
        #   equipements << (e.available ? "- #{e.name}" : "- ~~#{e.name}~~")
        # end

        # wounds = []
        # char.wounds.each do |w|
        #   wounds << "- #{w.name}"
        # end

        # wounds << '**HORS JEU**' if wounds.length == 2

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
