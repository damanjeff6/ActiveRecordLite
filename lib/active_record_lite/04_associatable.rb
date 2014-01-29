require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id,
    }

    defaults.each do |key, value|
      if options[key].nil?
        self.send("#{key}=",value)
      else
        self.send("#{key}=",options[key])
      end
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :class_name => name.to_s.singularize.camelcase,
      :primary_key => :id,
    }

    defaults.each do |key, value|
      if options[key].nil?
        self.send("#{key}=",value)
      else
        self.send("#{key}=",options[key])
      end
    end
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      key_value = self.send(options.foreign_key)
      options.model_class
             .where(options.primary_key => key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      key_value = self.send(options.primary_key)
      options.model_class
             .where(options.foreign_key => key_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
