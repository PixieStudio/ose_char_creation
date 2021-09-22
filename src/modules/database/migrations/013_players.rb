# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:players) do
      primary_key :id
      Bignum :user_discord_id
      Bignum :server_id
      Integer :participation, default: 0
    end
  end
end
