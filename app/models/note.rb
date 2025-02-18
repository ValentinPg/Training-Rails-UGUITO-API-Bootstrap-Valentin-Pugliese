# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :integer
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user

  enum note_type: { "review": 0, "critique": 1 }
  validates :title, :content, :note_type, presence: true
  validate :review_cap

  def word_count
    content.split.size
  end

  def content_length
    user.utility.content_length_criteria(word_count)
  end

  def review_cap
    if content_length != 'short' && note_type == 'review'
      errors.add(:note_type, :shorter_review)
    end
  end
end
