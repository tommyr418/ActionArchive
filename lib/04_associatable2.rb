require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      data = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{self.class.table_name}
        JOIN
          #{through_options.table_name} ON #{through_options.foreign_key} = #{self.class.table_name}.id
        JOIN
          #{source_options.table_name} ON #{source_options.foreign_key} = #{through_options.table_name}.id
        WHERE
          #{self.class.table_name}.id = ?
      SQL

      return nil if data.empty?
      source_options.model_class.new(data.first)
    end
  end
end
