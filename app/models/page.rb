require 'active_model'

class Page
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :url, :username, :topic

  validates_presence_of :url
  validates_length_of :topic, :minimum => 8
  validates_length_of :username, :minimum => 8

  def initialize(attributes = {})
    @attributes  = attributes
    @attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def inspect
    inspection = if @attributes
      @attributes.map{ |key, value| "#{key}: #{value}" }.join(", ")
    else
      "not initialized"
    end
    "#<#{self.class} #{inspection}>"
  end

end
