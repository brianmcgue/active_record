class Object
  def self.new_attr_accessor(*instance_variables)
    instance_variables.each do |instance_variable|
      i_var_with_at = "@#{instance_variable}"
      define_method("#{instance_variable}=") do |obj|
        instance_variable_set(i_var_with_at, obj)
      end
      define_method(instance_variable) do
        instance_variable_get(i_var_with_at)
      end
    end
    nil
  end
end