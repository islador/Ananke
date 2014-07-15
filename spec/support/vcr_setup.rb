require 'vcr'

VCR.configure do |c|
	c.allow_http_connections_when_no_cassette = false
	c.ignore_localhost = true
	#c.debug_logger = File.open(ARGV.first, 'w')
	c.cassette_library_dir = 'spec/vcr_cassettes'
	c.hook_into :webmock
	c.configure_rspec_metadata!
	c.default_cassette_options = {
    :match_requests_on => [:method, :path, :host], :record => :once, :erb => true
  }
end