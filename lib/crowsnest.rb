require 'pry'
require 'zk'
require 'platform-api'
require 'moneta'
require 'crowsnest/version'

class Class
  def descendants
    ObjectSpace.each_object(::Class).select {|klass| klass < self }
  end
end

module Crowsnest
  module Adapters
  end

  def self.create(options={})
    klass = Crowsnest::Adapters::Abstract
      .descendants
      .select { |adapter| adapter.name } # Filter out singleton classes.
      .reject { |adapter| adapter.name == 'Crowsnest::Adapters::Env' }
      .detect { |adapter| adapter.understands?(options) }
    klass ? klass.new(options) : Crowsnest::Adapters::Env.new(options)
  end
end

Dir.glob("#{File.dirname(__FILE__)}/crowsnest/adapters/**/*.rb").each do |f|
  require f
end
