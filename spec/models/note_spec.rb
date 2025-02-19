require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  it 'note_type must be review or critique' do
    note.note_type = 'rand'
    expect(note.save).to eq(false)
  end

  it { is_expected.to validate_presence_of(:title) }

  it { is_expected.to validate_presence_of(:content) }

  it { is_expected.to belong_to(:user) }
end
