module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_responese_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            title: note['TituloNota'],
            type: get_note_type(note),
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            user: get_user_info(note),
            book: get_book_info(note)
          }
        end
      end

      def get_user_info(note)
        firstname = note['NombreCompletoAutor'].split.last
        lastname = note['NombreCompletoAutor'].split.first
        {
          email: note['EmailAutor'],
          first_name: firstname,
          last_name: lastname
        }
      end

      def get_note_type(note)
        note['ReseniaNota'] ? 'review' : 'critique'
      end

      def get_book_info(note)
        {
          title: note['TituloLibro'],
          author: note['NombreCompletoAutor'],
          genre: note['GeneroLibro']
        }
      end
    end
  end
end
