class Crowsnest::Adapters::Abstract
  def self.understands?(options={})
    raise 'Implement this.'
  end

  def initialize(options={})
  end

  def register(name)
    raise 'Implement this.'
  end

  def heartbeat(name)
    raise 'Implement this.'
  end

  def heartbeat?(name)
    raise 'Implement this.'
  end

  def deregister(name)
    raise 'Implement this.'
  end

  def list(name)
    raise 'Implement this.'
  end
end
