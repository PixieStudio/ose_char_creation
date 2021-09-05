module Bot
  module Database
    # Settings Model
    class Rumeur < Sequel::Model
      def self.all(server_id)
        where(server_id: server_id).where(available: true).all
      end
    end
  end
end
