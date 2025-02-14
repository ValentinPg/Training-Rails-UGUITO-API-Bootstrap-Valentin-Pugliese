require 'rails_helper'

RSpec.describe Note, type: :model do
  subject(:note) do
    build(:note)
  end

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it 'note_type must be review or critique' do
    expect {note.note_type = 'rand'}.to raise_error(ArgumentError)
  end


  %i[title content].each do |value|
    it { is_expected.to validate_presence_of(value) }
  end

  it {is_expected.to belong_to(:user)}

  it 'word_length returns the number of characters in the content field' do
    expect(subject.word_count).to eq(subject.content.length)
  end
end
