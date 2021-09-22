# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:characters) do
      add_column :level, Integer, default: 1
      add_column :exp, Integer, type: :Bignum, default: 0
    end
  end
end
