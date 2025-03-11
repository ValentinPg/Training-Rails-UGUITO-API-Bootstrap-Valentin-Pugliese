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
        let(:type) { 'review' }

        it { expect(response_body.sample['type']).to eq(type) }

        it { expect(response_body.size).to eq(expected_size) }

        it { expect(response).to have_http_status(:ok) }
      end

      context 'when fetching critiques' do
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
        before { get :index, params: {} }

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

  describe 'POST #create' do
    let(:note_content) { { title: random_text, content: random_text, type: random_type } }
    let(:random_text) { Faker::Lorem.sentence(word_count: 5) }
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
        let(:message) { I18n.t('activerecord.errors.models.note.invalid_note_type') }

        it_behaves_like 'unprocessable entity with message'
      end

      context 'when missing params' do
        let(:note_content) { { title: random_text } }
        let(:message) { I18n.t('errors.messages.internal_server_error') }

        it_behaves_like 'bad request with message'
      end

      context 'when exceeding the review limit' do
        let(:random_text) { Faker::Lorem.sentence(word_count: user.utility.long) }
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

  describe 'GET #index_async' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let(:author) { Faker::Book.author }
      let(:params) { { author: author } }
      let(:worker_name) { 'RetrieveNotesWorker' }
      let(:parameters) { [params] }

      before { get :index_async, params: params }

      it 'returns status code accepted' do
        expect(response).to have_http_status(:accepted)
      end

      it 'returns the response id and url to retrive the data later' do
        expect(response_body.keys).to contain_exactly('response', 'job_id', 'url')
      end

      it 'enqueues a job' do
        expect(AsyncRequest::JobProcessor.jobs.size).to eq(1)
      end

      it 'creates the right job' do
        expect(AsyncRequest::Job.last.worker).to eq(worker_name)
      end
    end

    context 'when the user is not authenticated' do
      before { get :index_async }

      it 'returns status code unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
