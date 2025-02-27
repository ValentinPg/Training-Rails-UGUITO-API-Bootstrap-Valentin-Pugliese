module Api
  module V1
    class NotesController < ApplicationController
      rescue_from ActiveRecord::StatementInvalid, ArgumentError, with:
      :render_error

      def index
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

      def validate_order
        params[:order].present?
      end

      def render_error(_msg)
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end
    end
  end
end
