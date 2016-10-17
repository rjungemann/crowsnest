class Crowsnest::Adapters::Env < Crowsnest::Adapters::Abstract
  def self.understands?(options={})
    true
  end

  def initialize(options={})
  end

  def register(name)
  end

  def heartbeat(name)
  end

  def heartbeat?(name)
    false
  end

  def deregister(name)
  end

  def list(name)
    (ENV["CROWSNEST_ENV_#{name.upcase}"] || '').split(';')
  end
end
