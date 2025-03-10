FactoryBot.define do
  factory :utility do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    # Adds a number to the name to avoid duplicates and fail because of the uniqueness
    sequence(:name) { |n| "#{Faker::Lorem.word}#{n}" }
    type { Utility.subclasses.map(&:to_s).sample }
    short_note_length { Faker::Number.between(from: 10, to: 80) }
    long_note_length { Faker::Number.between(from: 81, to: 120) }
  end
end
