require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:type) { Note.note_types.keys.sample }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:expected_size) { Faker::Number.between(from: 5, to: 10) }
      let(:notes) { create_list(:note, expected_size, note_type: type, user: user) }
      let(:expected_keys) { %w[id title type content_length] }

      before do
        notes
        get :index, params: { type: type }
      end

      it { expect(response_body.sample.keys).to match_array(expected_keys) }

      context 'when fetching reviews' do
        before { create(:note, note_type: 'critique', user: user) }

        let(:type) { 'review' }

        it { expect(response_body.sample['type']).to eq(type) }

        it { expect(response_body.size).to eq(expected_size) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when fetching critiques' do
        before { create(:note, note_type: 'review', user: user) }

        let(:type) { 'critique' }

        it { expect(response_body.sample['type']).to eq(type) }

        it { expect(response_body.size).to eq(expected_size) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when passing page_size and page' do
        let(:random_number) { Faker::Number.between(from: 1, to: 30) }
        let(:page) { random_number }
        let(:page_size) { random_number }
        let(:test_subject) { user.notes }

        before { get :index, params: { type: type, page: page, page_size: page_size } }

        it_behaves_like 'paginated resource'
      end

      context 'when ordering results' do
        let(:random_item) { rand(0..(response_body.length - 2)) }
        let(:first_note) { Note.find(response_body[random_item]['id']) }
        let(:last_note) { Note.find(response_body[random_item + 1]['id']) }

        before do
          notes
          get :index, params: { type: type, order: order }
        end

        context 'with order asc' do
          let(:order) { 'asc' }

          it { expect(first_note.created_at).to be <= last_note.created_at }
        end

        context 'with order desc' do
          let(:order) { 'desc' }

          it { expect(first_note.created_at).to be >= last_note.created_at }
        end
      end

      context 'when passing invalid parameters' do
        before { get :index, params: { type: 'test' } }

        it { expect(response).to have_http_status(:bad_request) }
      end
    end

    context 'when there is not a user logged in' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:record) { create(:note, user: user) }
      let(:expected_keys) { %w[id title type content_length word_count created_at content user] }

      before { get :show, params: { id: record.id } }

      it_behaves_like 'basic show endpoint'

      it { expect(response_body.keys).to match_array(expected_keys) }
    end

    context 'when the user is not authenticated' do
      context 'when fetching an book' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
