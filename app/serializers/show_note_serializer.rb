class ShowNoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :word_count, :created_at, :content, :content_length
  belongs_to :user, serializer: UserSerializer

  delegate :word_count, :content_length, to: :object

  def type
    object.note_type
  end
end
