$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'billwise4r'
require 'rspec'
require 'rspec/autorun'
require 'fakeweb'
require 'awesome_print'

RSpec.configure do |config|

end
