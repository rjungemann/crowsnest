class Crowsnest::Adapters::Redis < Crowsnest::Adapters::Abstract
  EXPIRE_TIME_SECONDS = 10

  attr_reader :redis

  def self.understands?(options={})
    if options && options != {}
      !!options[:redis_url]
    end
    !!ENV['REDIS_URL']
  end

  def initialize(options={})
    @prefix = options[:redis_prefix] || ENV['REDIS_PREFIX']
    @redis = Redis.new(options[:redis_url] || ENV['REDIS_URL'])
  end

  def register(name)
    key = [@prefix, name, hostname].compact.join(':')
    value = Time.now.to_i
    @redis.set(key, EXPIRE_TIME_SECONDS, value)
  end

  def heartbeat(name)
    key = [@prefix, name, hostname].compact.join(':')
    @redis.expire(key, EXPIRE_TIME_SECONDS)
  end

  def deregister(name)
    key = [@prefix, name, hostname].compact.join(':')
    @redis.del(key)
  end

  def list(name)
    prefix = [@prefix, name].compact.join(':')
    keys = [prefix, '*'].compact.join(':')
    @redis.keys(keys).map { |key| key.gsub(Regexp.new("^#{prefix}:"), '') }
  end

  # -------
  # Helpers
  # -------

  def hostname
    Socket.gethostname
  end
end
