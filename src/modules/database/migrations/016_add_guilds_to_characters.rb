# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:characters) do
      add_foreign_key :guild_id, :guilds, default: nil, on_delete: :cascade
    end
  end
end
