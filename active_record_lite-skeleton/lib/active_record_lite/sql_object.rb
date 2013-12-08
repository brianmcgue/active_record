require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  # sets the table_name
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    where({"id" => "#{self.table_name}.id"})
    # results = DBConnection.execute(<<-SQL)
#       SELECT
#         *
#       FROM
#         #{self.table_name}
#     SQL
#
#     results.map do |params|
#       self.new(params)
#     end
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    where({"id" => id}).first
  end

  # call either create or update depending if id is nil.
  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  private
  # helper method to return values of the attributes.
  def attribute_values
    self.class.attributes.map do |variable|
      self.send(variable)
    end
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        [#{self.class.table_name}] (#{self.class.attributes.join(", ")})
      VALUES
        (#{(["?"] * attribute_values.length).join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
    nil
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    set_line = self.class.attributes.map do |variable|
      "#{variable} = ?"
    end.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, :id => self.id)
      UPDATE
        [#{self.class.table_name}]
      SET
        #{set_line}
      WHERE
        id = :id
    SQL
    nil
  end
end