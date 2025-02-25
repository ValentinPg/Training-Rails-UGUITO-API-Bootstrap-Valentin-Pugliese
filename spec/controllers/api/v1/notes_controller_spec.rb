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
        before { get :index, params: {} }

        let(:notes_expected) { critique }

        it { expect(response).to have_http_status(:bad_request) }
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

      let(:expected) { ShowNoteSerializer.new(note).to_json }

      context 'when fetching a book' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it { expect(response.body).to eq(expected) }

        it { expect(response).to have_http_status(:ok) }
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
