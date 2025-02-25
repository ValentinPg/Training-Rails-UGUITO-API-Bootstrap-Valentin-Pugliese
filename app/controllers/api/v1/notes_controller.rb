module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_params, only: [:index]

      rescue_from ActiveRecord::RecordInvalid, with:
         :unprocessable_entity_rp


      rescue_from ArgumentError, with:
         :render_error

      def index
        render json: paged_notes, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: note, status: :ok
      end

      def create
        nota = Note.create!(title: params[:note][:title], note_type: params[:note][:type],
                            content: params[:note][:content], user_id: current_user.id)
        render json: { message: 'Nota creada con exito' }
      end

      def ordered_notes
        user_notes.order(created_at: params[:order])
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

      def validate_params
        return if validate_type && validate_order
        raise Exceptions::InvalidParameterError
      end

      def validate_type
        Note.note_types.include?(params[:type])
      end

      def validate_order
        params[:order] ||= 'asc'
        %w[asc desc].include?(params[:order])
      end

      def unprocessable_entity_rp(msg)
        render json: { message: msg },
               status: :unprocessable_entity
      end

      def render_error(msg)
        render json: { message: msg },
               status: :bad_request
      end
    end
  end
end
