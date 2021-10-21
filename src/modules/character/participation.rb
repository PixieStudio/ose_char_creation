# frozen_string_literal: true

module Bot
  module Character
    # Embed module
    module Participation
      def self.add_one_pp(_event)
        puts 'Add 1 personnal PP'
      end

      def self.add_pp(_event)
        puts 'Add PP'
      end

      def self.remove_pp(_event)
        puts 'Remove PP'
      end
    end
  end
end
