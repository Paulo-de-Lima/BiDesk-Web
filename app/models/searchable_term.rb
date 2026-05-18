module SearchableTerm
  extend ActiveSupport::Concern

  class_methods do
    def ilike_search(columns, termo)
      termo = termo.to_s.strip
      return all if termo.blank?

      pattern = "%#{sanitize_sql_like(termo)}%"
      table = table_name
      clause = columns.map { |col| "#{table}.#{col} ILIKE :search_term" }.join(" OR ")
      where(clause, search_term: pattern)
    end
  end
end
