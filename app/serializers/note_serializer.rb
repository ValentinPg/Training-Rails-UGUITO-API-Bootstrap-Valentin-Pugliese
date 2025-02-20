class NoteSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :content_length

  delegate :content_length, to: :object

  def type
    object.note_type
  end
end
