Crowsnest
=========

by [Roger Jungemann](mailto:roger@thefifthcircuit.com)

Introduction
------------

Service discovery can be a challenge. Often the technique used in development
will not be the one used on production. The methods used on Heroku may be
different than the ones used on EC2.

Crowsnest is a Ruby library which sits on top of a number of different client
libraries to provide service discovery. Ideally, one would use something like
Zookeeper, but for testing, something like Moneta can be used instead.

Installation
------------

```sh
gem install crowsnest
```

Usage
-----

### Environment variables

Set some of the following environment variables:

```sh
# For the "Env" adapter:
CROWSNEST_ENV_WEB='some.host;some.other.host'

# For the "Heroku" adapter:
HEROKU_API_KEY='1234'
HEROKU_APP_NAME='falling-water-255'

# For the "Moneta" adapter:
MONETA_URL='moneta://Memory?prefix=registrations%3A'

# For the "Zookeeper" adapter:
ZOOKEEPER_URL='localhost:2181'
ZOOKEEPER_PREFIX='/registrations'

# For the "Redis" adapter:
REDIS_URL='redis://localhost:6379'
REDIS_PREFIX='registrations'
```

Then from your Ruby code:

```ruby
require 'crowsnest'

# Fetch some adapter based on environment variables set above.
adapter = Crowsnest.create

# Register this service.
adapter.register('web')
# You can also choose a key manually.
adapter.register('web', 'foo')

# If the process exits, try to deregister gracefully.
at_exit do
  adapter.deregister('web')
end

# If necessary, notify the discovery service periodically.
if adapter.heartbeat?
  Thread.new do
    loop do
      adapter.heartbeat('web')
      # Or...
      adapter.heartbeat('web', 'foo')

      sleep 5
    end
  end
end

# If you'd like to see what services are available:
adapter.list('web') #=> ['some.host']
```

### Options

Set some of the following options:

```ruby
# For the "Env" adapter:
options = nil

# For the "Heroku" adapter:
options = {
  heroku_api_key: '1234',
  heroku_app_name: 'falling-water-255'
}

# For the "Moneta" adapter:
options = {
  moneta_url: 'moneta://Memory?prefix=registrations%3A'
}

# For the "Zookeeper" adapter:
options = {
  zookeeper_url: 'localhost:2181',
  zookeeper_prefix: '/registrations'
}

# For the "Redis" adapter:
options = {
  redis_url: 'redis://localhost:6379',
  redis_prefix: 'registrations'
}
```

Then you can instantiate it like so:

```ruby
require 'crowsnest'

adapter = Crowsnest.create(options)
```

## Caveats

    TODO: Fill this out

## TODO

  * Fill out caveats.
  * Test prefixes for Redis and Zookeeper.
  * Show how to instantiate an adapter directly.
