FactoryBot.define do
  factory :note do
    title { Faker::Markdown.emphasis }
    content { Faker::Lorem.words(number: 5).join(' ') }
    note_type { Note.note_types.keys.sample }
    user
  end
end
