module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_responese_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            title: note['titulo'],
            type: note['tipo'],
            created_at: note['fecha_creacion'],
            content: note['contenido'],
            user: get_user_info(note['autor']),
            book: get_book_info(note['libro'])
          }
        end
      end

      def get_user_info(note)
        contact_data = note['datos_de_contacto']
        personal_data = note['datos_personales']
        {
          email: contact_data['email'],
          first_name: personal_data['nombre'],
          last_name: personal_data['apellido']
        }
      end

      def get_book_info(note)
        {
          title: note['titulo'],
          author: note['autor'],
          genre: note['genero']
        }
      end
    end
  end
end
