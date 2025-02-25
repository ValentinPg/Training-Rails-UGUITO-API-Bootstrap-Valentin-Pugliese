module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordInvalid, with:
         :bad_request_rp

      rescue_from Exceptions::NoteContentError, with:
      :note_content_rp

      rescue_from ArgumentError, ActiveRecord::StatementInvalid, with:
         :unprocessable_entity_rp

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
        params[:order] ||= 'asc'
        notes.order(created_at: params[:order])
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

      def unprocessable_entity_rp(_msg)
        render json: { error: I18n.t('activerecord.errors.models.note.unprocessable_entity') },
               status: :unprocessable_entity
      end

      def bad_request_rp(_msg)
        render json: { error: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end

      def note_content_rp
        render json: { error: I18n.t('activerecord.errors.models.note.shorter_review') },
               status: :unprocessable_entity
      end
    end
  end
end
