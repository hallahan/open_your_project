require 'active_model'

class Fork
  include ActiveModel::Validations

  attr_accessor :username, :topic
  attr_writer :url

  validates_presence_of :url
  validates_length_of :topic, :minimum => 8
  validates_length_of :username, :minimum => 8

  def initialize(attributes = {})
    p 333, attributes
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def url
    @url = "http://#{@url}" unless @url.to_s.match(%r{^https?://})
    @url
  end
end

