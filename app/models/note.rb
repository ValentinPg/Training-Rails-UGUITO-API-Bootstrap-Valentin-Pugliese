# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string
#  content    :string
#  note_type  :string
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :user

  validates :note_type, inclusion: {in: %w(review critique),
  message: "El atributo note_type tiene que ser 'review' o 'critique'"}
  validates :title, :content, presence: true
end
