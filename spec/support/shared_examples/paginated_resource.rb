shared_examples 'paginated resource' do
  let(:expected) { test_subject.page(page).per(page_size) }

  it 'returns the correct number of items' do
    expect(response_body.size).to eq(expected.size)
  end

  it 'returns te correct items' do
    expected_ids = expected.pluck(:id).to_set
    response_ids = response_body.map { |i| i['id'] }.to_set
    expect(response_ids).to eq(expected_ids)
  end
end
