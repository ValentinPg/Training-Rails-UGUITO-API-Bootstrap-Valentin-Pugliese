FactoryBot.define do
  factory :note do
    title {Faker::Markdown.emphasis}
    content {Faker::Markdown.emphasis}
    note_type {"review"}
    user
  end
end
