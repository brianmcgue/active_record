require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    where_params = params.map do |key, value|
      "#{key} = ?}"
    end.join(", ")

    puts params.values


    DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_params}
    SQL
    #
    # result = DBConnection.execute(<<-SQL, id)
    #   SELECT
    #     *
    #   FROM
    #     #{self.table_name}
    #   WHERE
    #     #{self.table_name}.id = ?
    # SQL
    #
    # result = where({self.table_name.id => id})
    #
    #
  end
end