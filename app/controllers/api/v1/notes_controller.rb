module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      rescue_from Exceptions::NoteContentError, with:
      :note_content_rp
      def index
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: note, status: :ok
      end

      def create
        Note.create!(title: params[:note][:title], note_type: params[:note][:type],
                     content: params[:note][:content], user_id: current_user.id)
        render json: { message: 'Nota creada con exito' }, status: :created
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

      def note_content_rp
        render_error('activerecord.errors.models.note.shorter_review', :unprocessable_entity)
      end

      def unprocessable_entity_msg
        'activerecord.errors.models.note.unprocessable_entity'
      end

      def bad_request_msg
        'activerecord.errors.models.note.invalid_parameter'
      end
    end
  end
end
