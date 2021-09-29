# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:characters) do
      add_column :selected, TrueClass, default: true
    end
  end
end
