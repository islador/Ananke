require 'vcr'

VCR.configure do |c|
	c.allow_http_connections_when_no_cassette = false
	c.cassette_library_dir = 'spec/vcr_cassettes'
	c.hook_into :webmock
	c.configure_rspec_metadata!
	c.default_cassette_options = { :record => :once, :erb => true }
end