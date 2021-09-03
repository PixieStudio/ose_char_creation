module Bot
  module DiscordCommands
    # Syncs expansions with db
    module Sync
      extend Discordrb::Commands::CommandContainer

      # Sync Classes
      command(:sync_classes) do |event|
        event.message.delete
        next unless event.user.owner?

        event.respond 'Synchronisation en cours...'

        Dir.glob('data/classes/*.yaml').each do |f|
          data = YAML.load_file(f)

          find_cle = Database::Classe.find(cle: data['cle'])
          next unless find_cle.nil?

          new_class = Database::Classe.new
          data.keys.each do |k|
            new_class[k] = data[k]
          end
          new_class.save
        end
        'Synchronisation terminée'
      end
    end
  end
end
