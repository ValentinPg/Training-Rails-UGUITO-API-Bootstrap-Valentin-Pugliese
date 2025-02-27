shared_examples 'test pagination' do
  it 'returns the correct number of items' do
    expect(response_body.size).to eq(page_size)
  end

  it 'returns te correct items' do
    expected_ids = test_subject.page(page).per(page_size).map { |i| i.id }
    response_ids = response_body.map { |i| i['id'] }
    expect(response_ids).to eq(expected_ids)
  end
end
