# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  note_type  :string           not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user

  validates :title, :content, :note_type, presence: true
  validate :note_type_validation

  def note_type_validation
    unless note_type == 'review' || note_type == 'critique'
      errors.add(:note_type,
                 'note_type must be review or critique')
    end
  end
end
