class ChangeNoteTypeToIntegerInNotes < ActiveRecord::Migration[6.1]
  def change
    change_column :notes, :note_type, :integer
  end
end
