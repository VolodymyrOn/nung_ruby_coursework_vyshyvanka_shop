module Admin
  module UnicodeSearch
    private

    def unicode_search(records, query, *fields)
      search_text = normalize_search_text(query)

      return records if search_text.blank?

      records.to_a.select do |record|
        fields.any? do |field|
          value = record.public_send(field)

          normalize_search_text(value).include?(search_text)
        end
      end
    end

    def normalize_search_text(value)
      value.to_s.unicode_normalize(:nfkc).downcase.strip
    end
  end
end
