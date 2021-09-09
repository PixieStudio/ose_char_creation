Sequel.migration do
  up do
    alter_table(:settings) do
      add_column :merchants_channel_id, Integer, type: :Bignum
    end
  end
end
