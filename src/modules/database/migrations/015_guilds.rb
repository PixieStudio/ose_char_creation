# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:guilds) do
      primary_key :id
      Bignum :server_id, null: false
      String :name, null: false
      Integer :gold, default: 0
    end
  end
end
