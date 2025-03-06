module UtilityService
  module South
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        {
          Autor: params['author']
        }
      end

      def retrieve_notes
        {
          Autor: params['author']
        }
      end
    end
  end
end
