$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'crowsnest'
RSpec.configure do |config|
  config.before(:each) do
    stub_const('ENV', {})
  end
end
