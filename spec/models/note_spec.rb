require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it 'note_type must be review or critique' do
    note.note_type = 'rand'
    expect(note.save).to eq(false)
  end


  %i[title content].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it {is_expected.to belong_to(:user)}

end
