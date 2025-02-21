module Api
  module V1
    class NotesController < ApplicationController
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
        Note.where(note_type: params[:type])
      end

      def find_note
        Note.find(params[:id])
      end
    end
  end
end
