require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:type) { Note.note_types.keys.sample }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:notes) { create_list(:note, 5, note_type: type, user: user) }

      before do
        notes
        get :index, params: { type: type }
      end

      context 'when fetching data' do
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes,
                                                            serializer: IndexNoteSerializer).to_json
        end

        context 'when fetching reviews' do
          let(:type) { 'review' }

          it { expect(response_body.to_json).to eq(expected) }

          it { expect(response).to have_http_status(:ok) }
        end

        context 'when fetching critiques' do
          let(:type) { 'critique' }

          it { expect(response_body.to_json).to eq(expected) }

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

        context 'when checking serializer attributes' do
          let(:body) { JSON.parse(expected) }

          %w[id title type content_length].each do |attribute|
            it { expect(body.first.keys).to include(attribute) }
          end
        end
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

      context 'when fetching a book' do
        before { get :show, params: { id: record.id } }

        it_behaves_like 'basic show endpoint'
      end

      context 'when checking serializer attributes' do
        let(:body) { JSON.parse(response_body.to_json) }
        let(:expected) { %w[id title type content_length word_count created_at content user].to_set }

        before { get :show, params: { id: record.id } }

        it { expect(response_body.keys).to match_array(expected) }
      end
    end

    context 'when the user is not authenticated' do
      context 'when fetching an book' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
