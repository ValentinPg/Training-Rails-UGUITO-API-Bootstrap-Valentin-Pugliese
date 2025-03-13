class AddNoteLengthToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :short_note_length, :integer, null: false
    add_column :utilities, :long_note_length, :integer, null: false
  end
end
