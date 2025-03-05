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
          let(:page) { 1 }
          let(:page_size) { 2 }
          let(:test_subject) { user.notes }

          before { get :index, params: { type: type, page: page, page_size: page_size } }

          it_behaves_like 'test pagination'
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

        it { expect(response).to have_http_status(:unprocessable_entity) }
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

  describe 'POST #create' do
    let(:note_content) { { title: random_text, content: random_text, type: random_type } }
    let(:random_text) { Faker::Lorem.sentence(word_count: 5)}
    let(:random_type) { Note.note_types.keys.sample }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'
      before { post :create, params: { note: note_content } }

      let(:created_note) { user.notes.where(title: note_content[:title]) }

      context 'when creating a note' do
        it { expect(response).to have_http_status(:created) }
        it { expect(created_note.exists?).to be true }
      end

      context 'when invalid wrong note_type' do
        let(:note_content) { { title: random_text, content: random_text, type: 'test' } }
        let(:message) { I18n.t('activerecord.errors.models.note.unprocessable_entity') }

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when missing params' do
        let(:note_content) { { title: random_text } }
        let(:message) { I18n.t('activerecord.errors.models.note.invalid_parameter') }

        it_behaves_like 'bad request with message'
      end

      context 'when exceeding the review limit' do
        let(:random_text) { Faker::Lorem.words(number: user.utility.long).join(' ') }
        let(:random_type) { 'review' }
        let(:message) { I18n.t('activerecord.errors.models.note.shorter_review') }

        it_behaves_like 'unprocessable entity with message'
      end
    end

    context 'when there is no user logged in' do
      before { post :create, params: { note: note_content } }

      it_behaves_like 'unauthorized'
    end
  end
end
