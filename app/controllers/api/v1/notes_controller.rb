module Api
  module V1
    class NotesController < ApplicationController
      def index
        return render_error unless valid_type?
        render json: paged_notes, status: :ok, each_serializer: NoteBriefSerializer
      end

      def show
        render json: note, status: :ok
      end

      private

      def ordered_notes
        should_order_notes? ? notes.order(created_at: params[:order]) : notes
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

      def should_order_notes?
        params[:order].present?
      end

      def render_error
        render json: { message: I18n.t('activerecord.errors.models.note.invalid_parameter') },
               status: :bad_request
      end

      def valid_type?
        Note.note_types.include?(params[:type])
      end
    end
  end
end
