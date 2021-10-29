# frozen_string_literal: true

module Bot
  module DiscordCommands
    # Show Tutorial
    module Tutorial
      extend Discordrb::Commands::CommandContainer

      admin_cmd = {
        ":tools:\u0009 !settings": 'Configuration des salons',
        ":ear:\u0009 !add rumeurs": 'Ajoute des rumeurs',
        "\u200B": "\u200B",
        ":compass:\u0009 !pp remove": 'Retirer un **pp** à un joueur',
        ":compass:\u0009 !pp ajouter": 'Ajouter un **pp** à un joueur',
        "\u200B ": "\u200B"
      }

      create_cmd = {
        ":new:\u0009 !c new": 'Crée un personnage',
        ":question:\u0009 !help": 'Action suivante disponible',
        ":game_die:\u0009 !c roll caracs": 'Lance toutes tes caractéristiques',
        ":muscle:\u0009 !FOR": 'Lance FORce',
        ":brain:\u0009 !INT": 'Lance INTelligence',
        ":owl:\u0009 !SAG": 'Lance SAGesse',
        ":fox:\u0009 !DEX": 'Lance DEXtérité',
        ":ox:\u0009 !CON": 'Lance CONstitution',
        ":crown:\u0009 !CHA": 'Lance CHARisme',
        ":diamond_shape_with_a_dot_inside:\u0009 !c classes": 'Classes disponibles',
        ":chains:\u0009 !c ajuster": 'Ajuster les caractéristiques',
        ":heart:\u0009 !c roll pv": 'Lancer les points de vie max.',
        ":coin:\u0009 !c po": "Pièces d'or de départ",
        ":speaking_head:\u0009 !c langues": 'Ajouter des langues connues',
        ":ear:\u0009 !rumeur": 'Entendre une rumeur',
        ":trident:\u0009 !c alignement": "Définir l'alignement",
        ":diamond_shape_with_a_dot_inside:\u0009 !c nom": 'Nommer le personnage',
        ":diamond_shape_with_a_dot_inside:\u0009 !c pronoms": 'Indiquer les pronoms',
        ":frame_photo:\u0009 !c avatar": 'Illustrer le personnage'
      }

      manage_cmd = {
        ":pushpin:\u0009 !c select": 'Sélectionne un de tes personnages',
        ":coin:\u0009 !c po": "Modifie le montant de tes Pièces d'Or",
        ":compass:\u0009 !pp": 'Ajoute 1 Point de Participation (lié au joueur)',
        ":star2:\u0009 !c exp": "Ton personnage gagne de l'expérience",
        ":headstone:\u0009 !c mort": 'Envoie ton personnage au cimetière',
        ":up:\u0009 !c sync": 'Synchronise ta feuille de personnage',
        "\u200B": "\u200B"
      }

      store_cmd = {
        ":moneybag:\u0009 !marchands": 'Commerce avec les marchands',
        "\u200B ": "\u200B",
        "\u200B": "\u200B"
      }

      guild_cmd = {
        ":new:\u0009 !g new [nom]": "Création d'une guilde",
        ":inbox_tray: \u0009 !g join": 'Rejoindre une guilde',
        ":outbox_tray:\u0008 !g quitter": 'Quitter une guilde',
        ":moneybag:\u0008 !g gold": 'Richesses de la guilde',
        ":x:\u0008 !g supprimer": "Détruire une guilde\n(Propriétaire du serveur)",
        "\u200B": "\u200B"
      }

      command :tuto do |event|
        settings = Character::Check.settings(event)

        creation_channel = settings.creation_channel_id
        merchants_channel = settings.merchants_channel_id

        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.timestamp = Time.now

        embed.title = 'COMMANDES : PROPRIÉTAIRE SERVEUR'
        embed.description = "*Ces commandes ne sont accessibles qu'au propriétaire du serveur.*\n\n"

        admin_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end

        event.channel.send_message('', false, embed)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.timestamp = Time.now

        embed.title = 'COMMANDES : CRÉATION DE PERSONNAGE'
        embed.description = '*Commandes disponibles pour la création de la feuille de personnage'\
                         ' uniquement dans le salon '\
                         "#{creation_channel.nil? ? 'de création' : BOT.channel(creation_channel).mention}*\n\n"

        create_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end

        event.channel.send_message('', false, embed)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.timestamp = Time.now

        embed.title = 'COMMANDES : GESTION DE PERSONNAGE'
        embed.description = '*Commandes disponibles pour la gestion du personnage'\
                         ' uniquement dans le salon '\
                         "#{creation_channel.nil? ? 'de création' : BOT.channel(creation_channel).mention}*\n\n"

        manage_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end

        event.channel.send_message('', false, embed)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.timestamp = Time.now

        embed.title = 'COMMANDES : COMMERCE'
        embed.description = '*Commandes disponibles pour le commerce'\
                         ' uniquement dans le salon '\
                         "#{merchants_channel.nil? ? 'de création' : BOT.channel(merchants_channel).mention}*\n\n"

        store_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end

        event.channel.send_message('', false, embed)

        embed = Discordrb::Webhooks::Embed.new
        embed.color = '#9932CC'
        embed.timestamp = Time.now

        embed.title = 'COMMANDES : GESTION DE GUILDE'
        embed.description = '*Commandes disponibles pour la gestion de guilde'\
                         ' uniquement dans le salon '\
                         "#{creation_channel.nil? ? 'de création' : BOT.channel(creation_channel).mention}*\n\n"

        guild_cmd.each do |k, v|
          embed.add_field name: k, value: v, inline: true
        end

        event.channel.send_message('', false, embed)
      end
    end
  end
end
