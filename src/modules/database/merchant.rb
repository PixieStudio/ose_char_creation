module Bot
  module Database
    # Settings Model
    class Merchant < Sequel::Model
      one_to_many :merchants_items, class: '::Bot::Database::MerchantsItem'
    end
  end
end
