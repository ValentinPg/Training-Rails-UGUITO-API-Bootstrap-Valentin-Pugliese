require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching data' do
        let!(:expected) do
          ActiveModel::Serializer::CollectionSerializer.new(notes,
                                                            serializer: IndexNoteSerializer).to_json
        end

        context 'when fetching reviews' do
          before do
            notes
            get :index, params: { type: 'review' }
          end

          let(:notes) { create_list(:note, 3, note_type: 'review', user: user) }

          it { expect(response_body.to_json).to eq(expected) }

          it { expect(response).to have_http_status(:ok) }
        end

        context 'when fetching critiques' do
          before do
            notes
            get :index, params: { type: 'critique' }
          end

          let(:notes) { create_list(:note, 3, note_type: 'critique', user: user) }

          it { expect(response_body.to_json).to eq(expected) }

          it { expect(response).to have_http_status(:ok) }
        end

        context 'when passing page_size and page' do
          let(:page) { 1 }
          let(:page_size) { 2 }
          let(:notes) { create_list(:note, 2, note_type: 'critique', user: user) }

          before { get :index, params: { type: 'critique', page: page, page_size: page_size } }

          it { expect(response_body.to_json).to eq(expected) }
        end

        context 'when checking serializer attributes' do
          before { get :index, params: { type: 'review' } }

          let(:notes) { create_list(:note, 3, 'review', user: user) }
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

        let(:notes) { create_list(:note, 20, user: user) }

        context 'with order asc' do
          before do
            notes
            get :index, params: { type: 'critique', order: 'asc' }
          end

          it {
            expect(first_note.created_at).to be <= last_note.created_at
          }
        end

        context 'with order desc' do
          before do
            notes
            get :index, params: { type: 'critique', order: 'desc' }
          end

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

        it { expect(body.keys.to_set.difference(expected)).to be_empty }
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
