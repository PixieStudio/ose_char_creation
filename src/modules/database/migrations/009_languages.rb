# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:languages) do
      primary_key :id
      String :name
    end
  end
end
