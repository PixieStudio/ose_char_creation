module Bot
  module Database
    # Settings Model
    class Settings < Sequel::Model
      def server
        BOT.server(server_id)
      end

      def creation_channel
        0o0000000
      end

      def sheet_channel
        0o00000000
      end
    end
  end
end
