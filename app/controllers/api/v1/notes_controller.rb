module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_type, only: [:index]
      def index
        render json: ordered_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: find_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def ordered_notes
        find_notes.order(created_at: params[:order]).page(params[:page]).per(params[:page_size])
      end

      def find_notes
        notes.where(note_type: params[:type])
      end

      def find_note
        notes.find(params[:id])
      end

      def notes
        current_user.notes
      end

      def validate_type
        return if Note.note_types.include?(params[:type])
        raise Exceptions::InvalidParameterError
      end

      def render_error(_msg)
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_type') },
               status: :bad_request
      end
    end
  end
end
