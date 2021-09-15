# frozen_string_literal: true

# Gems
require 'sequel'
require 'yaml'

module Bot
  # SQL Database
  module Database
    # Load migrations
    Sequel.extension :migration

    CONFIG = YAML.load_file("#{Dir.pwd}/data/config.yaml")

    # Connect to database
    DB = Sequel.connect(CONFIG['database_url'])

    # Run migrations
    Sequel::Migrator.run(DB, 'src/modules/database/migrations')

    # Load models
    Dir['src/modules/database/*.rb'].each { |mod| load mod }

    # Initialize database (maybe)
    def self.init!
      # sync with data/dah-cards
    end
  end
end
