require_relative 'db_connection'

module Searchable
  def where(params)
    where_string = params.keys.join(" = ? AND ") + " = ?"
    data = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_string}
    SQL

    return [] if data.empty?
    data.map { |datum| self.new(datum) }
  end
end
