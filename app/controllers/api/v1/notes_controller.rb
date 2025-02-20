module Api
  module V1
    class NotesController < ApplicationController
      before_action :validate_params

      def index
        render json: filtered_notes, status: :ok, each_serializer: NoteSerializer
      end

      def show; end

      private

      def filtered_notes
        Note.where(note_type: params[:type]).order(created_at: params[:order]).page(params[:page]).per(params[:page_size])
      end

      def validate_params
        valid_types = %w[review critique]
        return if valid_types.include?(params[:type])
        render json: { error: 'Invalid type' }, status: :bad_request
      end
    end
  end
end
