# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:characters) do
      add_column :death, String
      add_column :avatar_url, String, default: 'https://i.imgur.com/Q7B91HT.png'
      add_column :languages, String, default: ''
    end
  end
end
