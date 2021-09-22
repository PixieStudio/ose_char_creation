# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:classes) do
      add_column :exp5, String, default: ''
      add_column :exp10, String, default: ''
    end
  end
end
