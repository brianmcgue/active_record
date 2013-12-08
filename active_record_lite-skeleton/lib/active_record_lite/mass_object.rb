class MassObject
  # takes a list of attributes.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
   self.attributes.concat(attributes)
  end

  # takes a list of attributes.
  # makes getters and setters
  def self.my_attr_accessor(*attributes)
    attributes.each do |attribute|
      with_at = "@#{attribute}"
      define_method("#{attribute}=") do |obj|
        instance_variable_set(with_at, obj)
      end
      define_method(attribute) do
        instance_variable_get(with_at)
      end
    end
    nil
  end


  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes ||= []
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    [].tap do |objects|
      results.each do |params|
        objects << self.new(params)
      end
    end
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
    params.each do |attr_name, attr_val|
      attr_name = attr_name.to_sym unless attr_name.is_a?(Symbol)
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", attr_val)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end
