Sequel.migration do
  up do
    create_table(:characters) do
      primary_key :id
      Bignum :discord_id
      String :discord_name
      Bignum :server_id
      #   foreign_key :game_id, :games, on_delete: :cascade
      #   foreign_key :livret_id, :livrets, on_delete: :cascade
      # Bignum :text_channel_id, unique: true
      # Bignum :fiche_msg_id, unique: true
      # Integer :livret, default: 0
      String :char_name, default: 'A définir'
      String :genre, default: 'A définir'
      # foreign_key :classe_id, :classes, on_delete: :cascade
      # Or ?
      # Integer :classe, default: 0
      Integer :dexterite, default: 0
      Integer :force, default: 0
      Integer :sagesse, default: 0
      Integer :intelligence, default: 0
      Integer :constitution, default: 0
      Integer :charisme, default: 0
      String :personnalite, default: 'A définir'
      String :apparence, default: 'A définir'
      # Integer :first_skill, default: 0
      # Integer :second_skill, default: 0
      # String :first_wound, default: 'Aucune'
      # String :second_wound, default: 'Aucune'
      # String :histoire, default: 'Empty'
      TrueClass :editable, default: true
      # Integer :level, default: 0
    end
  end
end
