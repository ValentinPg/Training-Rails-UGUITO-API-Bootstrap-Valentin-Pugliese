require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  context 'when a note is created' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_presence_of(:note_type) }
    it { is_expected.to belong_to(:user) }
  end

  context 'when assigning an invalid note_type' do
    it { expect { create(:note, note_type: 'rand') }.to raise_error(ArgumentError) }
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

#   context 'when a note is a critique' do

#     context 'when is short, medium or long' do
#     end
# end
# context 'when a note is a review and not short' do
#   let(:south_user) { create(:user, utility: create(:south_utility)) }
#   let(:north_user) { create(:user, utility: create(:north_utility)) }
#   let(:long_review) { create(:note, note_type: 'review') } it 'NorthUtility' do
#       long_review.user = north_user
#       long_review.content = Faker::Lorem.words(number: (long_review.utility.short + 1)).join(' ')
#       expect { long_review.save! }.to raise_error(ActiveRecord::RecordInvalid)
#     end

#     it 'SouthUtility limit is 60' do
#       long_review.user = south_user
#       long_review.content = Faker::Lorem.words(number: (long_review.utility.short + 1)).join(' ')
#       expect { long_review.save! }.to raise_error(ActiveRecord::RecordInvalid)
#     end
#   end
# end
