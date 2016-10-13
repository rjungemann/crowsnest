class Crowsnest::Adapters::Heroku < Crowsnest::Adapters::Abstract
  attr_reader :heroku

  def self.understands?(options={})
    if options && options != {}
      !!(options[:heroku_api_key] && options[:heroku_app_name])
    end
    !!(ENV['HEROKU_API_KEY'] && ENV['HEROKU_APP_NAME'])
  end

  def initialize(options={})
    @app_name = options[:heroku_app_name] || ENV['HEROKU_APP_NAME']
    @heroku = PlatformAPI.connect(options[:heroku_api_key] || ENV['HEROKU_API_KEY'])
  end

  def register(name)
  end

  def heartbeat(name)
  end

  def deregister(name)
  end

  def list(name)
    @heroku
      .formation
      .list(@app_name)
      .select { |info| info['type'] == name }
      .map { |info| info['id'] }
  end
end
