require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name] || name.to_s.capitalize
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.capitalize.singularize
    @foreign_key = options[:foreign_key] || (self_class_name.downcase.to_s + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      data = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{options.table_name}.*
        FROM
          #{self.class.table_name}
        JOIN
          #{options.table_name} ON #{options.foreign_key} = #{options.table_name}.id
        WHERE
          #{self.class.table_name}.id = ?
      SQL

      return nil if data.empty?
      options.model_class.new(data.first)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      data = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{options.table_name}.*
        FROM
          #{self.class.table_name}
        JOIN
          #{options.table_name} ON #{options.foreign_key} = #{self.class.table_name}.id
        WHERE
          #{self.class.table_name}.id = ?
      SQL

      return [] if data.empty?
      data.map { |datum| options.model_class.new(datum) }
    end
  end

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

  def assoc_options
    @assoc_options ||= {}
  end
end
