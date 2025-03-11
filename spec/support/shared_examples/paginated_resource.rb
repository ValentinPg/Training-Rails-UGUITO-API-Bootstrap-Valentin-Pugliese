shared_examples 'paginated resource' do
  let(:expected) { test_subject.page(page).per(page_size) }

  it 'returns the correct number of items' do
    expect(response_body.size).to eq(expected.size)
  end

  it 'returns te correct items' do
    expected_ids = expected.pluck(:id)
    response_ids = response_body.pluck(:id)
    expect(response_ids).to match_array(expected_ids)
  end
end
