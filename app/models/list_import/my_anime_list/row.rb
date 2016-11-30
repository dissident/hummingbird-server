class ListImport
  class MyAnimeList
    class Row
      attr_reader :obj

      def initialize(obj)
        @obj = obj.deep_symbolize_keys
      end

      def type
        @type ||= if obj.key? :anime_title then :anime
                  elsif obj.key? :manga_title then :manga
                  else raise "Invalid type"
                  end
      end

      def klass
        type.to_s.classify.safe_constantize
      end

      def media
        key = "#{type}/#{media_key(:id)}"
        Mapping.lookup('myanimelist', key) || Mapping.guess(klass, media_info)
      end

      def media_info
        {
          id: media_key(:id),
          title: media_key(:title),
          show_type: media_key(:media_type_string),
          episode_count: media_key(:num_episodes),
          chapter_count: media_key(:num_chapters)
        }.compact
      end

      def status
        case obj[:status]
        when 1 then :current
        when 2 then :completed
        when 3 then :on_hold
        when 4 then :dropped
        when 6 then :planned
        end
      end

      def media_key(key)
        obj["#{type}_#{key}".to_sym]
      end

      def progress
        obj[:num_read_chapters] || obj[:num_watched_episodes]
      end

      def volumes
        obj[:num_read_volumes]
      end

      def rating
        obj[:score].to_f / 2
      end

      def notes
        obj[:tags]
      end

      def start_date
        Date.strptime(obj[:start_date_string], '%F')
      rescue ArgumentError
        nil
      end

      def finish_date
        Date.strptime(obj[:finish_date_string], '%F')
      rescue ArgumentError
        nil
      end

      def data
        %i[status progress rating volumes].map do |k|
          [k, send(k)]
        end.to_h
      end
    end
  end
end
