VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.filter_sensitive_data('BITGO_ACCESS_TOKEN') do
    CGI.escape YAML.load_file("#{Rails.root}/config/application.yml")['bitgo_admin']['access_token']
  end

  c.ignore_request do |req|
    uri = URI(req.uri)
    uri.host == '127.0.0.1' && uri.port == 35792 ||   # test server
      uri.host == 'localhost' && uri.port == 8981     # solr
  end

  c.register_request_matcher :blindfolded_body do |a, b|
    if [a, b].all? { |req| (uri = URI(req.uri)).host == 'localhost' && uri.port == 3080 && uri.query == '/api/v1/wallets/simplecreate' }
      blindfold = { 'label' => nil }

      JSON.parse(a.body).merge(blindfold) == JSON.parse(b.body).merge(blindfold)
    else
      true
    end
  end

  c.default_cassette_options = {
    allow_playback_repeats: true,
    match_requests_on: [:method, :host, :path, :query, :blindfolded_body],
    serialize_with: :syck,
    decode_compressed_response: true
  }
end
