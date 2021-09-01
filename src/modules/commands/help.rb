module Bot
  module DiscordCommands
    # Help command
    module Help
      extend Discordrb::Commands::CommandContainer

      command :help do |event|
        event.message.delete
        msg = []
        msg << '```md'
        msg << '# LISTE DES COMMANDES #'
        msg << '============================='
        msg << '[commande](Description)'
        msg << ''
        if event.user.owner?
          msg << 'Serveur Owner :'
          msg << '-----------------------------------------'
          msg << '[!sync_moves](Synchronisation des Moves et Livrets)'
          msg << '[!sync_tables](Synchronisation des Tables Aléatoires)'
          msg << ''
        end
        if event.user.role?(CONFIG.maitre_dino)
          msg << 'Commandes MD :'
          msg << '-----------------------------------------'
          msg << "Uniquement dans le salon #{BOT.channel(CONFIG.new_game).name} :"
          msg << '[!new](Créer une nouvelle partie.)'
          msg << ''
          msg << 'Uniquement dans le salon *#information-partie* correspondant :'
          msg << '[!start](Début de la partie. Ferme les inscriptions.)'
          msg << '[!end](Clôture la partie. Les salons sont en lecture seule.)'
          msg << ''
        end
        msg << 'Commandes Joueurs :'
        msg << '-----------------------------------------'
        msg << 'Uniquement dans le salon `#information-partie` correspondant :'
        msg << '[!inscription](Vous inscrire dans la partie.)'
        msg << ''
        msg << 'Dans votre salon `#votre-nom-personnage` :'
        msg << 'La liste des commandes est disponible dans le premier message de votre salon.'
        msg << ''
        msg << 'Dans tous les salons de la catégorie `PARTIE N - Zone de Jeu` :'
        msg << "[!move](Liste des Manoeuvres qui vous sont accessibles. Indiquez le numéro de la manoeuvre souhaitée pour l'utiliser lorsque Tricy vous le demande.)"
        msg << '[!move nom de la manoeuvre](Lance directement la manoeuvre et les dés, en fonction de votre fiche.)'
        msg << '```'

        res = event.respond msg.join("\n")
        sleep 300
        res.delete
      end
    end
  end
end
