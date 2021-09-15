Sequel.migration do
  up do
    alter_table(:characters) do
      add_column :death, String
      add_column :avatar_url, String, default: 'https://i.imgur.com/Q7B91HT.png'
    end
  end
end
