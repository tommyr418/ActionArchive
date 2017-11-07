require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class ActionArchive
  extend Searchable
  extend Associatable

  def self.columns
    @col_data ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @col_data[0].map(&:to_sym)
  end

  def self.finalize!
    columns.each do |attribute|
      define_method(attribute) { attributes[attribute] }
      define_method("#{attribute}=") { |val| attributes[attribute] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.inherited(subclass)
    subclass.table_name = 'humans' if subclass.name == "Human"
    subclass.finalize!
  end

  def self.all
    all_data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(all_data)
  end

  def self.parse_all(results)
    results.map { |datum| self.new(datum) }
  end

  def self.find(id)
    all_data = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    return nil if all_data.empty?
    self.new(all_data.first)
  end

  def initialize(params = {})
    params.each do |k, v|
      raise "unknown attribute '#{k}'" unless self.class.columns.include?(k.to_sym)
      self.send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = []

    self.class.columns.map do |col|
      values << self.send(col)
    end

    values
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(", ")

    question_marks = []
    cols.length.times { question_marks << "?"}
    question_string = question_marks.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_string})
    SQL

    self.send(:id=, DBConnection.last_insert_row_id)
    self.class.new(attributes)
  end

  def update
    cols = self.class.columns
    col_names = cols.join(" = ?, ") + " = ?"

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
