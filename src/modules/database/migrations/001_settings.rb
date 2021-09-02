Sequel.migration do
  up do
    create_table(:settings) do
      primary_key :id
      Bignum :server_id, unique: true
      Bignum :creation_channel_id
      Bignum :sheet_channel_id
    end
  end
end
