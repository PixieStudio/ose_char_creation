# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:classes) do
      primary_key :id
      String :cle
      String :name
      String :main_attributes
      Integer :force, default: 0
      Integer :intelligence, default: 0
      Integer :constitution, default: 0
      Integer :dexterite, default: 0
      Integer :sagesse, default: 0
      Integer :charisme, default: 0
      String :dv, default: '1d6'
      Integer :max_lvl, default: 0
      String :armors, default: 'all'
      String :weapon, default: 'all'
      String :spells, text: true, default: 'none'
      String :languages, text: true, default: 'none'
      Integer :save_mp, default: 0
      Integer :save_b, default: 0
      Integer :save_pp, default: 0
      Integer :save_s, default: 0
      Integer :save_ssb, default: 0
      String :page, default: 'p.1'
    end
  end
end
