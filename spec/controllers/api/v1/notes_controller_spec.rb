require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:review) { create(:note, note_type: 'review', user: user) }
    let(:critique) { create(:note, note_type: 'critique', user: user) }
    # let!(:expected) do
    #     ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
    #                                                       serializer: IndexNoteSerializer).to_json
    #   end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) { [IndexNoteSerializer.new(notes_expected).as_json.deep_stringify_keys] }

      context 'when fetching reviews' do
        before { get :index, params: { type: 'review', order: 'asc', page: 1, page_size: 1 } }

        let(:notes_expected) { review }

        it do
          expect(response_body).to eq(expected)
        end

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when fetching critiques' do
        before { get :index, params: { type: 'critique', order: 'asc', page: 1, page_size: 1 } }

        let(:notes_expected) { critique }

        it { expect(response_body).to eq(expected) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when ordering asc' do
      end

      context 'when ordering desc' do
      end

      context 'when passing invalid parameters' do
        before { get :index, params: {} }

        let(:notes_expected) { critique }

        it { expect(response).to have_http_status(:bad_request) }
      end

      context 'when passing page_size and page' do
      end
    end

    context 'when there is not a user logged in' do
      before { get :index }

      it_behaves_like 'unauthorized'
    end
  end
end
