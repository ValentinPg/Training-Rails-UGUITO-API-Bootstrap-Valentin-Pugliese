module Api
  module V1
    class NotesController < ApplicationController
      def index
        raise Exceptions::InvalidParameterError unless validate_type
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: note, status: :ok
      end

      private

      def ordered_notes
        validate_order ? notes.order(created_at: params[:order]) : notes
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

      def validate_type
        Note.note_types.include?(params[:type])
      end

      def validate_order
        unless (params.key?(:order) && %w[asc
                                          desc].include?(params[:order])) || !params.key?(:order)
          raise Exceptions::InvalidParameterError
        end
      end

      def render_error(_msg)
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end
    end
  end
end
