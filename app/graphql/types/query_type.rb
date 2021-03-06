module Types
  class QueryType < Types::BaseObject

    field :chapters, [Types::ChapterType], null: false do
      argument :language, String, required: false, default_value: 'en'
    end
    def chapters(language: 'en')
      Chapter.includes("#{language}_translated_names".to_sym).all
    end

    field :chapter, Types::ChapterType, null: false do
      argument :id, ID, required: true
    end
    def chapter(id:)
      Chapter.find_by_id(id)
    end

    field :chapter_info, Types::ChapterInfoType, null: false do
      argument :chapter_id, ID, required: true
      argument :language, String, required: false, default_value: 'en'
    end
    def chapter_info(id:, language: 'en')
      ChapterInfo.where(chapter_id: chapter_id).filter_by_language_or_default(language)
    end

    field :juzs, [Types::JuzType], null: false
    def juzs
      Juz.all
    end

    field :verses, [Types::VerseType], null: false do
      argument :chapter_id, ID, required: true
      argument :language, String, required: false, default_value: 'en'
      argument :offset, Int, required: false, default_value: 0
      argument :padding, Int, required: false, default_value: 0
      argument :page, Int, required: false, default_value: 1
      argument :limit, Int, required: false, default_value: 10, prepare: ->(limit, ctx) {
        limit <= 50 ? limit : 50
      }
    end
    def verses(chapter_id:, language:, offset:, padding:, page:, limit:)
      eager_words = [
        "#{language}_translations".to_sym,
        "#{language}_transliterations".to_sym
      ]

      Verse
      .where(chapter_id: chapterId)
      .preload(:media_contents, words: eager_words)
      .page(page)
      .per(limit)
      .offset(offset)
      .padding(padding)
    end

    field :verse, Types::VerseType, null: false do
      argument :id, ID, required: false
    end
    def verse(id:)
      Verse.find_by_id(id)
    end

    field :verse_by_verse_key, Types::VerseType, null: false do
      argument :verse_key, String, required: true
    end
    def verse_by_verse_key(verse_key:)
      Verse.find_by_verse_key(verse_key)
    end

    field :tafsirs, [Types::TafsirType], null: false do
      argument :verse_id, ID, required: false
      argument :verse_key, String, required: false
    end
    def tafsirs(verse_id:, verse_key:)
      if verse_id.present?
        Tafsir.where(verse_id: verse_id)
      else
        Tafsir.where(verse_key: verse_key)
      end
    end

    field :words, [Types::WordType], null: false do
      argument :verse_id, ID, required: false
      argument :verse_key, String, required: false
    end
    def words(verse_id:, verse_key: '')
      if verse_id
        Word.where(verse_id: verse_id)
      else
        Word.where(verse_key: verse_key)
      end
    end

    field :audio_files, [Types::AudioFileType], null: false do
      argument :recitation_id, ID, required: true
      argument :resource_ids, [ID], required: true
      argument :resource_type, String, default_value: 'Verse', required: false
    end
    def audio_files(args)
        AudioFile.where(
          resource_id: args[:resource_ids],
          resource_type: args[:resource_type],
          recitation_id: args[:recitation_id]
        )
    end

    field :audio_file, Types::AudioFileType, null: false do
      argument :recitation_id, ID, required: true
      argument :resource_id, ID, required: true
      argument :resource_type, String, default_value: 'Verse', required: false
    end
    def audio_file(args)
      AudioFile.where(
        resource_id: args[:resource_id],
        resource_type: args[:resource_type],
        recitation_id: args[:recitation_id]
      ).first
    end

    field :search_verses, Types::SearchResultsType, null: true do
      argument :query, String, required: true
      argument :page, Int, required: false, default_value: 1
      argument :size, Int, required: false, default_value: 20
      argument :language, String, required: false, default_value: 'en'
    end
    def search_verses(query:, page:, size:, language:)
      client = Search::Client.new(
        query,
        page: page, size: size, lanugage: language
      )
      response = client.search

      {
        query: query,
        total_count: response.total_count,
        took: response.took,
        current_page: response.current_page,
        total_pages: response.total_pages,
        per_page: response.per_page,
        results: response.results
      }
    end
  end
end
