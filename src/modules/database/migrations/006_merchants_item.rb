Sequel.migration do
  up do
    create_table(:merchants_items) do
      primary_key :id
      String :name, unique: true
      Integer :price, default: 0
      Integer :weight, default: 0
      foreign_key :merchant_id, :merchants, on_delete: :cascade
    end
  end
end
