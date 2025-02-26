require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:review) { create_list(:note, 3, note_type: 'review', user: user) }
    let(:critique) { create_list(:note, 3, note_type: 'critique', user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: IndexNoteSerializer).to_json
      end

      context 'when fetching reviews' do
        before { get :index, params: { type: 'review', order: 'asc' } }

        let(:notes_expected) { review }

        it { expect(response_body.to_json).to eq(expected) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when fetching critiques' do
        before { get :index, params: { type: 'critique', order: 'asc' } }

        let(:notes_expected) { critique }

        it { expect(response_body.to_json).to eq(expected) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when ordering asc' do
        before { get :index, params: { type: 'critique', order: 'asc' } }

        let(:notes_expected) { critique }
        let(:first_note) { Note.find(response_body.first['id']) }
        let(:last_note) { Note.find(response_body.last['id']) }

        it { expect(first_note.created_at).to be <= last_note.created_at }
      end

      context 'when ordering desc' do
        before { get :index, params: { type: 'critique', order: 'desc' } }

        let(:notes_expected) { critique }
        let(:first_note) { Note.find(response_body.first['id']) }
        let(:last_note) { Note.find(response_body.last['id']) }

        it { expect(first_note.created_at).to be >= last_note.created_at }
      end

      context 'when passing invalid parameters' do
        before { get :index, params: { type: 'test' } }

        let(:notes_expected) { critique }

        it { expect(response).to have_http_status(:unprocessable_entity) }
      end

      context 'when passing page_size and page' do
        let(:page) { 1 }
        let(:page_size) { 2 }
        let(:notes_expected) { critique.first(2) }

        before { get :index, params: { type: 'critique', order: 'asc', page: page, page_size: page_size } }

        it { expect(response_body.to_json).to eq(expected) }
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
    let(:random_text) { Faker::Lorem.words(number: 5).join(' ') }
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
