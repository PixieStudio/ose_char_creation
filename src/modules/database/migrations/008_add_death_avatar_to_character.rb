# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:characters) do
      add_column :death, String
      add_column :avatar_url, String, default: 'https://i.imgur.com/Q7B91HT.png'
      add_column :languages, String, default: ''
      add_column :gold_protection, TrueClass, default: false
      add_column :ajuster_protection, TrueClass, default: false
    end
  end
end
