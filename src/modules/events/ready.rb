module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Ready
      extend Discordrb::EventContainer
      ready do |event|
        event.bot.game = CONFIG.game

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

        puts 'Synchronisation des classes terminées.'
      end
    end
  end
end
