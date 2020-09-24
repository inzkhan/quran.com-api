class RemoveUnusedPolymorphic < ActiveRecord::Migration[6.0]
  def up
    AudioFile.where(resource_type: 'Word').delete_all

    rename_column :audio_files, :resource_id, :verse_id
    remove_column :audio_files, :resource_type

    add_index :audio_files, :verse_id

    rename_column :verses, :sajdah, :sajdah_type
    rename_column :verses, :text_madani, :text_uthmani
    rename_column :verses, :text_simple, :text_imlaei_simple

    rename_column :words, :text_madani, :text_uthmani
    rename_column :words, :text_simple, :text_imlaei_simple
    add_column :words, :text_madani_tajweed, :string

    rename_column :tokens, :text_madani, :text_uthmani
    rename_column :tokens, :text_clean, :text_imlaei_simple
    add_column :tokens, :text_imlaei, :string
    add_column :tokens, :text_uthmani_tajweed, :string
  end

  def down
    remove_index :audio_files, :verse_id
    rename_column :audio_files, :verse_id, :resource_id
    add_column :audio_files, :resource_type, :string

    rename_column :verses, :sajdah_type, :sajdah
    rename_column :verses, :text_uthmani, :text_madani
    rename_column :verses, :text_imlaei_simple, :text_simple

    rename_column :words, :text_uthmani, :text_madani
    rename_column :words, :text_imlaei_simple, :text_simple
    remove_column :words, :text_madani_tajweed

    rename_column :tokens, :text_uthmani, :text_madani
    rename_column :tokens, :text_imlaei_simple, :text_clean
    remove_column :tokens, :text_imlaei
    remove_column :tokens, :text_uthmani_tajweed
  end
end