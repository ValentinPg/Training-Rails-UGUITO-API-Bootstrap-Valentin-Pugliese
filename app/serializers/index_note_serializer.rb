class NoteBriefSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :content_length

  def type
    object.note_type
  end
end
