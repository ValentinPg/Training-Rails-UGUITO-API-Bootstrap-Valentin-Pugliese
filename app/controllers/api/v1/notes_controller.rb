module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        unless valid_type?(params[:type])
          return render_error(:invalid_note_type,
                              invalid_note_type)
        end
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def index_async
        response = execute_async(RetrieveNotesWorker, current_user.id, index_async_params)
        async_custom_response(response)
      end

      def show
        render json: note, status: :ok
      end

      def create
        return render_error(:invalid_note_type, invalid_note_type) unless create_params

        current_user.notes.create!(title: params[:note][:title], note_type: params[:note][:type],
                                   content: params[:note][:content])
        render json: { message: I18n.t('activerecord.models.note.created_with_success') },
               status: :created
      end

      private

      def create_params
        require_nested({ 'title': true, 'content': true, 'type': true }, params[:note])
        valid_type?(params[:note][:type])
      end

      def index_async_params
        params.require(:author)
      end

      def ordered_notes
        validate_order ? notes.order(created_at: params[:order]) : notes
      end

      def paged_notes
        ordered_notes.page(params[:page]).per(params[:page_size])
      end

      def notes
        user_notes.where(note_type: params[:type])
      end

      def note
        user_notes.find(params[:id])
      end

      def user_notes
        current_user.notes
      end

      def validate_order
        params.key?(:order)
      end

      def valid_type?(type)
        Note.note_types.keys.include?(type)
      end

      def invalid_note_type
        { message: I18n.t('activerecord.errors.models.note.invalid_note_type'),
          status: :unprocessable_entity }
      end
    end
  end
end
