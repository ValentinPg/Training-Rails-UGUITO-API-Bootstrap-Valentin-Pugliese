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
    it 'note_type must be review or critique' do
      expect { note.note_type = 'rand' }.to raise_error(ArgumentError)
    end
  end

  context 'when a note is a review and not short' do
    let(:north_utility_user) { create(:user, utility: :north_utility) }
    let(:south_utility_user) { create(:user, utility: :south_utility) }
    let(:long_review) { create(:note, note_type: 'review') }

    it 'NorthUtility limit is 50' do
      long_review.content = 10.times.map { 'test' }
      expect { long_review.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
