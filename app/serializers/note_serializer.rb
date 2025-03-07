class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :word_count, :created_at, :content, :content_length
  belongs_to :user

  def type
    object.note_type
  end
end
