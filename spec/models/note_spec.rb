require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  context 'when a note is created' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:note_type) }
    it { is_expected.to belong_to(:user) }
  end

  context 'when assigning a note_type' do
    it 'must be review or critique' do
      expect { note.note_type = 'rand' }.to raise_error(ArgumentError)
    end
  end

  context 'when a note is a review and not short' do
    let(:south_user) { create(:user, utility: create(:south_utility)) }
    let(:north_user) { create(:user, utility: create(:north_utility)) }
    let(:long_review) { create(:note, note_type: 'review') }

    it 'NorthUtility' do
      long_review.user = north_user
      long_review.content = Faker::Lorem.words(number: (long_review.utility.short + 1)).join(' ')
      expect { long_review.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'SouthUtility limit is 60' do
      long_review.user = south_user
      long_review.content = Faker::Lorem.words(number: (long_review.utility.short + 1)).join(' ')
      expect { long_review.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
