# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:merchants) do
      primary_key :id
      String :cle
      String :name
      String :rank
    end
  end
end
