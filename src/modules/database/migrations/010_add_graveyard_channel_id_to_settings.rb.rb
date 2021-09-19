# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:settings) do
      add_column :graveyard_channel_id, Integer, type: :Bignum
    end
  end
end
