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
    errors.add(:note_type, I18n.t('activerecord.errors.models.note.shorter_review'))if content_length != 'short' && note_type == 'review'
  end
end
