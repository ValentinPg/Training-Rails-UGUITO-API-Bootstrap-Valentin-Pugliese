module Api
  module V1
    class NotesController < ApplicationController
      def index
        # hacer con return unless y render error
        raise Exceptions::InvalidParameterError unless validate_params
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: note, status: :ok
      end

      private

      def ordered_notes
        notes.order(created_at: params[:order])
      end

      def paged_notes
        ordered_notes.page(params[:page]).per(params[:page_size])
      end

      def notes
        Note.where(note_type: params[:type])
      end

      def note
        Note.find(params[:id])
      end

      def validate_params
        validate_type && validate_order
      end

      def validate_type
        Note.note_types.include?(params[:type])
      end

      def validate_order
        params[:order] ||= 'asc'
        %w[asc desc].include?(params[:order])
      end

      def render_error(_msg)
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end
    end
  end
end
