Sequel.migration do
  up do
    create_table(:characters) do
      primary_key :id
      Bignum :user_discord_id
      Bignum :server_id
      String :message_id, unique: true
      String :char_name, default: 'A définir'
      String :genre, default: 'A définir'
      foreign_key :classe_id, :classes, on_delete: :cascade
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
      String :histoire, text: true, default: 'A définir'
      Integer :participation, default: 0
      Integer :ca, default: 0
      TrueClass :editable, default: true
    end
  end
end
