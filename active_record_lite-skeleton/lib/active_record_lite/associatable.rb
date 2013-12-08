require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    new_params = {
      :class_name => name,
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
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
