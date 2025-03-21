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
        critique.update!(content: Faker::Lorem.words(number: critique.utility.short).join(' '))
        expect(critique.content_length).to eq('short')
      end
    end

    context 'when content is medium' do
      it do
        critique.update!(content: Faker::Lorem.words(number: (critique.utility.short + 1)).join(' '))
        expect(critique.content_length).to eq('medium')
      end
    end

    context 'when content is long' do
      it do
        critique.update!(content: Faker::Lorem.words(number: critique.utility.long + 1).join(' '))
        expect(critique.content_length).to eq('long')
      end
    end
  end

  context 'when a note is a review' do
    subject(:review) { create(:note, note_type: 'review') }

    context 'when is medium' do
      let(:medium) { Faker::Lorem.words(number: (review.utility.short + 1)).join(' ') }

      it { expect { review.update!(content: medium) }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context 'when is long' do
      let(:long) { Faker::Lorem.words(number: (review.utility.long + 1)).join(' ') }

      it { expect { review.update!(content: long) }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
