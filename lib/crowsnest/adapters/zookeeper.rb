class Crowsnest::Adapters::Zookeeper < Crowsnest::Adapters::Abstract
  def self.understands?(options={})
    if options && options != {}
      !!options[:zookeeper_url]
    end
    !!ENV['ZOOKEEPER_URL']
  end

  def initialize(options={})
    @prefix = options[:zookeeper_prefix] || ENV['ZOOKEEPER_PREFIX'] || ''
    @zk = ZK.new(options[:zookeeper_url] || ENV['ZOOKEEPER_URL'])
  end

  def register(name, key=hostname)
    @zk.create("#{@prefix}/#{name}/#{key}", 'true', ephemeral: true)
  end

  def heartbeat(name, key=hostname)
  end

  def heartbeat?(name)
    false
  end

  def deregister(name)
    @zk.delete("#{@prefix}/#{name}/#{hostname}")
  end

  def list(name)
    paths = []
    @zk.find("/#{name}") { |path|
      simplified_path = path.gsub(Regexp.new("^#{@prefix}/#{name}/?"), '')
      next if simplified_path.empty?
      paths << simplified_path
    }
    paths
  end

  # -------
  # Helpers
  # -------

  def hostname
    Socket.gethostname
  end
end
