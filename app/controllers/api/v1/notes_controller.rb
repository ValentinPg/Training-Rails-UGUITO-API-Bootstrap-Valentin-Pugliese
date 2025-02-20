class NotesController < ApplicationController
  def index
    @notes = Note.all
    render json: @notes
  end

  def show; end
end
