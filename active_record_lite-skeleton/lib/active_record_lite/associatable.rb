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
  attr_accessor :name, :params, :foreign_key, :primary_key
  def initialize(name, params)
    new_params = {
      :class_name => name.to_s.split("_").map{|w| w.capitalize}.join(""),
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => "id".to_sym
    }

    params.each do |key, value|
      new_params[key] = value
    end

    @name = name
    @params = new_params
    @foreign_key = new_params[:foreign_key]
    @primary_key = new_params[:primary_key]
  end
end

class HasManyAssocParams < AssocParams
  attr_accessor :name, :params, :foreign_key, :primary_key
  def initialize(name, params, self_class)
    new_params = {
      :class_name => name.to_s.camelcase.singularize,
      :foreign_key => "#{self_class}_id".to_sym,
      :primary_key => "id".to_sym
    }

    params.each do |key, value|
      new_params[key] = value
    end

    @name = name
    @params = new_params
    @foreign_key = new_params[:foreign_key]
    @primary_key = new_params[:primary_key]
  end
end

module Associatable
  def assoc_params
    # decide on a better name -- this will do for the time being
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    self.assoc_params[name] = aps
    define_method(name) do
      key = self.send(aps.foreign_key)
      aps.other_class.where(aps.primary_key => key).first
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
    self.assoc_params[name] = aps
    define_method(name) do
      key = self.send(aps.primary_key)
      aps.other_class.where(aps.foreign_key => key)
    end
  end

  def has_one_through(name, through_name, source_name)
    through_params = self.assoc_params[through_name]
    define_method(name) do
      source_params = through_params.other_class.assoc_params[source_name]
      key1 = self.send(through_params.foreign_key)

      results = DBConnection.execute(<<-SQL, key1)
        SELECT
          #{source_params.other_table}.*
        FROM
          #{through_params.other_table}
        JOIN
          #{source_params.other_table}
        ON
          #{through_params.other_table}.#{source_params.foreign_key} = 
            #{source_params.other_table}.#{source_params.primary_key}
        WHERE
          #{through_params.other_table}.#{through_params.primary_key} = ?
      SQL

      source_params.other_class.parse_all(results).first
    end
  end
end
