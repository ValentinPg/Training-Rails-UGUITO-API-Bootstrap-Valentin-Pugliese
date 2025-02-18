require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) { create(:note) }

  context 'when a note is created' do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:content) }

    it { is_expected.to belong_to(:user) }
  end

  context 'when assigning a note_type' do
    it 'note_type must be review or critique' do
      expect { note.note_type = 'rand' }.to raise_error(ArgumentError)
    end
  end
end
