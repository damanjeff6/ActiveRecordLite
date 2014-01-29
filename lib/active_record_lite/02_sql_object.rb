require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map{ |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
         #{table_name}.id = ?
    SQL
    parse_all(result).first
  end

  def insert
    columns = self.class.attributes.join(', ')
    question_marks = (["?"] * self.class.attributes.count).join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{columns})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def save
    id.nil? ? self.insert : self.update
  end

  def update
    column_values =
      self.class.attributes.map do |attribute|
        "#{attribute} = ?"
      end

    column_values_string = column_values.join(', ')

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column_values_string}
      WHERE
        id = ?
    SQL
  end

  def attribute_values
    self.class.attributes.map do |attribute|
      self.send(attribute)
    end
  end
end
