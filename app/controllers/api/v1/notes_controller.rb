module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

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
        user_notes.where(note_type: params[:type])
      end

      def note
        user_notes.find(params[:id])
      end

      def user_notes
        current_user.notes
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
