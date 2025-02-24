require 'rails_helper'

describe API::V1::NotesController, type: :controller do
  describe 'GET #index' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'
      context 'when fetching critiques' do
      end

      context 'when fetching reviews' do
      end

      context 'when ordering asc' do
      end

      context 'when ordering desc' do
      end

      context 'when passing invalid parameters' do
      end

      context 'when passing page_size and page' do
      end
    end

    context 'when there is not a user logged in' do
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'
    end
  end
end
