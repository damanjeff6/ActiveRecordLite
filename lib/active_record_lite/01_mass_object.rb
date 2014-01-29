require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    attributes_array = new_attributes.map{|attribute| attribute.to_sym}
    self.attributes.concat(attributes_array)
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end

    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr_name, value|

      if self.class.attributes.include?(attr_name.to_sym)
        attr_name_sym = attr_name.to_sym
        self.send("#{attr_name_sym}=",value)
      else
        raise "mass assignment to unregistered attribute '#{attr_name.to_s}'"
      end
    end

  end
end
