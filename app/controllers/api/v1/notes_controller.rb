module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: filtered_notes, status: :ok, each_serializer: NoteSerializer
      end

      def show; end

      private

      def filtered_notes
        Note.where(note_type: params[:type]).order(:created_at).page(params[:page]).per(params[:page_size])
      end
    end
  end
end
