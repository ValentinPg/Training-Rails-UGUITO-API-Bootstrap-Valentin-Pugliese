module Api
  module V1
    class NotesController < ApplicationController
      before_action :validate_params, only: [:index]
      def index
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: find_note, status: :ok
      end

      private

      def ordered_notes
        find_notes.order(created_at: params[:order])
      end

      def paged_notes
        ordered_notes.page(params[:page]).per(params[:page_size])
      end

      def find_notes
        Note.where(note_type: params[:type])
      end

      def find_note
        Note.find(params[:id])
      end

      def validate_params
        return if validate_type && validate_order
        raise Exceptions::InvalidParameterError
      end

      def validate_type
        Note.note_types.include?(params[:type])
      end

      def validate_order
        %w[asc desc].include?(params[:order])
      end

      def render_error(_msg)
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end
    end
  end
end
