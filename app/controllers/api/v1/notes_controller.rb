module Api
  module V1
    class NotesController < ApplicationController
      def index
        @note_type = params[:type]
        @notes = Note.all
        render json: @notes
      end

      def show; end
    end
  end
end
