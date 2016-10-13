require 'spec_helper'

describe Crowsnest do
  it 'has a version number' do
    expect(Crowsnest::VERSION).not_to be nil
  end
end

describe Crowsnest do
  describe '.create' do
    it 'returns an Env adapter if there are no valid adapters' do
      expect(Crowsnest.create).to be_a(Crowsnest::Adapters::Env)
    end

    it 'returns a Heroku adapter from options'

    it 'returns a Heroku adapter from environment variables' do
      ENV['HEROKU_API_KEY'] = '123'
      ENV['HEROKU_APP_NAME'] = 'falling-water-123'
      expect(Crowsnest.create).to be_a(Crowsnest::Adapters::Heroku)
    end

    it 'returns a Zookeeper adapter from options'

    it 'returns a Zookeeper adapter from environment variables' do
      ENV['ZOOKEEPER_URL'] = 'localhost:2181'
      expect(Crowsnest.create).to be_a(Crowsnest::Adapters::Zookeeper)
    end

    it 'returns a Redis adapter from options'

    it 'returns a Redis adapter from environment variables'

    it 'returns a Moneta adapter from options'

    it 'returns a Moneta adapter from environment variables' do
      ENV['MONETA_URL'] = 'moneta://Memory'
      expect(Crowsnest.create).to be_a(Crowsnest::Adapters::Moneta)
    end
  end
end

describe Crowsnest::Adapters::Heroku do
  describe '#initialize' do
    it 'can be created from options'
    it 'can be created from environment variables'
  end

  describe '.understands?' do
    it 'returns true if options are passed and they match'
    it 'returns false if options are passed and they do not match'
    it 'returns true if environment variables are present and they match'
    it 'returns false if environment variables are present and they do not match'
  end

  describe '#register' do
    it 'does nothing'
  end

  describe '#heartbeat' do
    it 'does nothing'
  end

  describe '#deregister' do
    it 'does nothing'
  end

  describe '#list' do
    it 'lists all hosts for a certain name' do
      ENV['HEROKU_API_KEY'] = '1234'
      ENV['HEROKU_APP_NAME'] = 'someapp'
      api_key = nil
      allow(PlatformAPI).to receive(:connect) { |key| api_key = key }
      adapter = Crowsnest.create
      expect(adapter).to respond_to(:heroku)
      expect(api_key).to eq('1234')

      allow(adapter.heroku).to receive(:formation) {
        Class
          .new {
            def list(app_name)
              if app_name == 'someapp'
                [
                  { 'type' => 'web', 'id' => '1' },
                  { 'type' => 'web', 'id' => '2' },
                  { 'type' => 'worker', 'id' => '3' },
                  { 'type' => 'web', 'id' => '4' }
                ]
              else
                []
              end
            end
          }
          .new
      }
      expect(adapter.list('web')).to eq(%w(1 2 4))
    end
  end
end

describe Crowsnest::Adapters::Zookeeper do
  describe '#initialize' do
    it 'can be created from options'
    it 'can be created from environment variables'
  end

  describe '.understands?' do
    it 'returns true if options are passed and they match'
    it 'returns false if options are passed and they do not match'
    it 'returns true if environment variables are present and they match'
    it 'returns false if environment variables are present and they do not match'
  end

  describe '#register' do
    it 'registers a host'
  end

  describe '#heartbeat' do
    it 'does nothing'
  end

  describe '#deregister' do
    it 'deregisters a host'
  end

  describe '#list' do
    it 'lists all hosts for a certain name'
  end
end

describe Crowsnest::Adapters::Redis do
  describe '#initialize' do
    it 'can be created from options'
    it 'can be created from environment variables'
  end

  describe '.understands?' do
    it 'returns true if options are passed and they match'
    it 'returns false if options are passed and they do not match'
    it 'returns true if environment variables are present and they match'
    it 'returns false if environment variables are present and they do not match'
  end

  describe '#register' do
    it 'registers a host'
  end

  describe '#heartbeat' do
    it 'renews a host'
  end

  describe '#deregister' do
    it 'deregisters a host'
  end

  describe '#list' do
    it 'lists all hosts for a certain name'
  end
end

describe Crowsnest::Adapters::Moneta do
  describe '#initialize' do
    it 'can be created from options'
    it 'can be created from environment variables'
  end

  describe '.understands?' do
    it 'returns true if options are passed and they match'
    it 'returns false if options are passed and they do not match'
    it 'returns true if environment variables are present and they match'
    it 'returns false if environment variables are present and they do not match'
  end

  describe '#register' do
    it 'registers a host' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      adapter = Crowsnest.create
      expect(adapter).to respond_to(:moneta)
      expect(adapter.moneta.fetch('foo')).to be_nil
      expect(adapter.moneta.adapter.backend).to_not have_key('registrations:foo')
      allow(adapter).to receive(:hostname) { 'test.host' }
      adapter.register('foo')
      expect(adapter.moneta.adapter.backend).to have_key('registrations:foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test.host'])
      allow(adapter).to receive(:hostname) { 'test2.host' }
      adapter.register('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test.host', 'test2.host'])
    end

    it 'expires old hosts' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      now = Time.now.to_i
      adapter = Crowsnest.create
      adapter.moneta.store('foo', {
        'test.host' => now - 10,
        'test2.host' => now
      })
      allow(adapter).to receive(:hostname) { 'test3.host' }
      adapter.register('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test2.host', 'test3.host'])
    end
  end

  describe '#heartbeat' do
    it 'renews a host' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      adapter = Crowsnest.create
      now = Time.now.to_i
      adapter.moneta.store('foo', {
        'test.host' => now - 10
      })
      expect(adapter.moneta.fetch('foo')).to eq({
        'test.host' => now - 10
      })
      allow(adapter).to receive(:hostname) { 'test.host' }
      adapter.heartbeat('foo')
      hosts = adapter.moneta.fetch('foo')
      expect(hosts.keys).to eq(['test.host'])
      expect(hosts['test.host']).to be >= now
    end

    it 'expires old hosts' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      now = Time.now.to_i
      adapter = Crowsnest.create
      adapter.moneta.store('foo', {
        'test.host' => now - 10,
        'test2.host' => now
      })
      allow(adapter).to receive(:hostname) { 'test.host' }
      adapter.heartbeat('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test.host', 'test2.host'])
    end
  end

  describe '#deregister' do
    it 'deregisters a host' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      now = Time.now.to_i
      adapter = Crowsnest.create
      adapter.moneta.store('foo', {
        'test.host' => now,
        'test2.host' => now
      })
      allow(adapter).to receive(:hostname) { 'test.host' }
      adapter.deregister('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test2.host'])
    end

    it 'expires old hosts' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      now = Time.now.to_i
      adapter = Crowsnest.create
      adapter.moneta.store('foo', {
        'test.host' => now - 10,
        'test2.host' => now,
        'test3.host' => now
      })
      allow(adapter).to receive(:hostname) { 'test2.host' }
      adapter.deregister('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test3.host'])
    end
  end

  describe '#list' do
    it 'lists hosts' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      adapter = Crowsnest.create
      allow(adapter).to receive(:hostname) { 'test.host' }
      adapter.register('foo')
      expect(adapter.list('foo')).to eq(['test.host'])
      allow(adapter).to receive(:hostname) { 'test2.host' }
      adapter.register('foo')
      expect(adapter.list('foo')).to eq(['test.host', 'test2.host'])
    end

    it 'expires old hosts' do
      ENV['MONETA_URL'] = 'moneta://Memory?prefix=registrations%3A'
      now = Time.now.to_i
      adapter = Crowsnest.create
      adapter.moneta.store('foo', {
        'test.host' => now - 10,
        'test2.host' => now,
      })
      adapter.list('foo')
      expect(adapter.moneta.fetch('foo').keys).to eq(['test2.host'])
    end
  end
end

describe Crowsnest::Adapters::Env do
  describe '#initialize' do
    it 'can be created from options'
    it 'can be created from environment variables'
  end

  describe '.understands?' do
    it 'returns true if options are passed and they match'
    it 'returns false if options are passed and they do not match'
    it 'returns true if environment variables are present and they match'
    it 'returns false if environment variables are present and they do not match'
  end

  describe '#register' do
    it 'does nothing'
  end

  describe '#heartbeat' do
    it 'does nothing'
  end

  describe '#deregister' do
    it 'does nothing'
  end

  describe '#list' do
    it 'lists all hosts for a certain name' do
      ENV['CROWSNEST_ENV_WEB'] = 'host1;host2;host3'
      adapter = Crowsnest.create
      expect(adapter.list('web')).to eq(%w(host1 host2 host3))
    end
  end
end
