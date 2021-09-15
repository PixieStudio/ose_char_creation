# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:rumeurs) do
      primary_key :id
      Bignum :server_id
      String :content
      TrueClass :available, default: true
    end
  end
end
