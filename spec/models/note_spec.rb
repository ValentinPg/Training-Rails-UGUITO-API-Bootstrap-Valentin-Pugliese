require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  context 'when a note is created' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:note_type) }
    it { is_expected.to belong_to(:user) }
    it { expect { create(:note, note_type: 'rand') }.to raise_error(ArgumentError) }
  end

  describe '#word_count' do
    let(:random) { rand(1..5) }
    let(:simple_note) { create(:note, content: Faker::Lorem.words(number: random)) }

    it { expect(simple_note.word_count).to eq(random) }
  end

  describe '#content_length' do
    let(:critique) { create(:note, note_type: 'critique') }

    context 'when content is short' do
      it do
        critique.update!(content: Faker::Lorem.sentence(word_count: critique.utility.short_note_length))
        expect(critique.content_length).to eq('short')
      end
    end

    context 'when content is medium' do
      it do
        critique.update!(content: Faker::Lorem.sentence(word_count: (critique.utility.short_note_length + 1)))
        expect(critique.content_length).to eq('medium')
      end
    end

    context 'when content is long' do
      it do
        critique.update!(content: Faker::Lorem.sentence(word_count: critique.utility.long_note_length + 1))
        expect(critique.content_length).to eq('long')
      end
    end
  end

  context 'when a note is a review' do
    subject(:review) { create(:note, note_type: 'review') }

    context 'when is medium' do
      let(:medium) { Faker::Lorem.sentence(word_count: (review.utility.short_note_length + 1)) }

      it { expect { review.update!(content: medium) }.to raise_error(Exceptions::NoteContentError) }
    end

    context 'when is long' do
      let(:long) { Faker::Lorem.sentence(word_count: (review.utility.long_note_length + 1)) }

      it { expect { review.update!(content: long) }.to raise_error(Exceptions::NoteContentError) }
    end
  end
end
