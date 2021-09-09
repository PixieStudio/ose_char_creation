module Bot
  module Database
    # Settings Model
    class MerchantsItem < Sequel::Model
      many_to_one :merchant, class: '::Bot::Database::Merchant'
    end
  end
end
