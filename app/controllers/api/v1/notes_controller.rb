module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: note, status: :ok
      end

      def create
        current_user.notes.create!(title: create_params[:title], note_type: create_params[:type],
                                   content: create_params[:content])
        render json: { message: I18n.t('activerecord.models.note.created_with_success') },
               status: :created
      end

      private

      def create_params
        require_nested({ 'title': true, 'content': true, 'type': true }, params[:note])
        params[:note]
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
    end
  end
end
