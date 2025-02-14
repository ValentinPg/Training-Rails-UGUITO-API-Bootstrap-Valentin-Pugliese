class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.string :content
      t.string :note_type
      t.belongs_to :user, :foreign_key => { :on_update => :cascade }
      t.timestamps
    end
  end
end
