class Crowsnest::Adapters::Moneta < Crowsnest::Adapters::Abstract
  EXPIRE_TIME_SECONDS = 10

  attr_reader :moneta

  def self.understands?(options={})
    if options && options != {}
      !!options[:moneta_url]
    end
    !!ENV['MONETA_URL']
  end

  def initialize(options=nil)
    uri = URI.parse(options[:moneta_url] || ENV['MONETA_URL'])
    raise 'URL must begin with "moneta://"' unless uri.scheme == 'moneta'
    adapter = uri.hostname.to_sym
    options = CGI
      .parse(uri.query || '')
      .inject({}) { |h, (k, v)| h[k.to_sym] = v.first; h }
    @moneta = ::Moneta.new(adapter, options)
  end

  def register(path)
    mutex = ::Moneta::Mutex.new(@moneta, "#{path}:lock")
    mutex.synchronize do
      values = @moneta.fetch(path) || {}
      values[hostname] = Time.now.to_i
      @moneta.store(path, values)
      cleanup(path)
    end
  end

  # NOTE: You are responsible for calling `heartbeat` approximately every
  # `EXPIRE_TIME_SECONDS * 0.5`. You will likely want to do this in a
  # thread or reactor.
  def heartbeat(path)
    register(path)
  end

  def heartbeat?(name)
    true
  end

  def deregister(path)
    mutex = ::Moneta::Mutex.new(@moneta, "#{path}:lock")
    mutex.synchronize do
      values = @moneta.fetch(path) || {}
      values.delete(hostname)
      @moneta.store(path, values)
      cleanup(path)
    end
  end

  def list(path)
    mutex = ::Moneta::Mutex.new(@moneta, "#{path}:lock")
    values = nil
    mutex.synchronize do
      values = cleanup(path)
    end
    values
  end

  # -------
  # Helpers
  # -------

  # NOTE: Must be done inside a mutex. This will return the current list of
  # values.
  def cleanup(path)
    now = Time.now.to_i
    old_values = @moneta.fetch(path) || {}
    new_values = {}
    old_values.each do |k, v|
      new_values[k] = v if now - v < EXPIRE_TIME_SECONDS
    end
    @moneta.store(path, new_values)
    new_values.keys
  end

  def hostname
    Socket.gethostname
  end
end
