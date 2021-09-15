# frozen_string_literal: true

module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Ready
      extend Discordrb::EventContainer
      ready do |event|
        event.bot.game = CONFIG.game

        # Import Classes
        Dir.glob('data/classes/*.yaml').each do |f|
          data = YAML.load_file(f)

          find_cle = Database::Classe.find(cle: data['cle'])
          unless find_cle.nil?
            data.keys.each do |k|
              find_cle.update(k => data[k]) unless find_cle[k] == data[k]
            end
          end
          next unless find_cle.nil?

          new_class = Database::Classe.new
          data.keys.each do |k|
            new_class[k] = data[k]
          end
          new_class.save
        end

        # Import Merchants
        Dir.glob('data/merchants/*.yaml').each do |f|
          data = YAML.load_file(f)

          find_cle = Database::Merchant.find(cle: data['cle'])
          next unless find_cle.nil?

          Database::Merchant.create(
            cle: data['cle'],
            name: data['name'],
            rank: data['rank']
          )
        end

        # Import Merchants Store
        Dir.glob('data/merchants/*.yaml').each do |f|
          data = YAML.load_file(f)
          merchant = Database::Merchant.find(cle: data['cle'])

          data['store'].each.with_index(0) do |store, index|
            item = Database::MerchantsItem.find(name: store)
            next unless item.nil?

            new_item = Database::MerchantsItem.create(
              name: store,
              price: data['price'][index],
              merchant: merchant
            )
            new_item.update(weight: data['weight'][index]) if data['weight']
          end
        end

        puts 'Synchronisation des classes terminées.'
      end
    end
  end
end
