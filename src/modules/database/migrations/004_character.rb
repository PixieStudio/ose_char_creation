Sequel.migration do
  up do
    create_table(:characters) do
      primary_key :id
      Bignum :user_discord_id
      Bignum :server_id
      String :message_id, unique: true
      String :char_name, default: '!nom'
      String :genre, default: '!pronoms'
      foreign_key :classe_id, :classes, on_delete: :cascade
      Integer :dexterite, default: 0
      Integer :force, default: 0
      Integer :sagesse, default: 0
      Integer :intelligence, default: 0
      Integer :constitution, default: 0
      Integer :charisme, default: 0
      Integer :pv_max, default: 0
      Integer :gold, default: 0
      Integer :ca, default: 0
      String :alignement, default: '!alignement'
      String :rumeur, default: '` !rumeur `'
      String :personnalite, default: '` !personnalite `'
      String :apparence, default: '` !apparence `'
      String :histoire, text: true, default: '` !histoire `'
      Integer :participation, default: 0
      TrueClass :editable, default: true
    end
  end
end
