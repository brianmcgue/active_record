require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'
require 'debugger'

class AssocParams
  def other_class
    self.params[:class_name].constantize
  end

  def other_table
    self.other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_accessor :name, :params
  def initialize(name, params)
    new_params = {
      :class_name => name.to_s.split("_").map{|w| w.capitalize}.join(""),
      :foreign_key => "#{name}_id",
      :primary_key => "id"
    }

    params.each do |key, value|
      new_params[key] = value
    end

    @name = name
    @params = new_params
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    define_method(name) do
      key = self.send(aps.params[:foreign_key])
      puts key
      # debugger
      results = DBConnection.execute(<<-SQL, key)
        SELECT
          *
        FROM
          #{aps.other_table}
        WHERE
          #{aps.other_table}.#{aps.params[:primary_key]} = ?
      SQL

      aps.other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
