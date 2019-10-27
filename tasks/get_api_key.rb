#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'json'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    uri = URI.parse("https://#{kwargs[:rancher_server]}/v3/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri, 'Content-type' => 'application/json')

    request['Authorization'] = "Bearer #{kwargs[:login_token]}"
    request.body = { type: 'token', decription: 'automation' }.to_json

    response = http.request(request)

    raise Puppet::Error, _("Cannot get API key with token #{kwargs[:login_token]}: #{response.body}") if response.code != '201'

    # Obtain the token
    api_key = JSON.parse(response.body)['token']

    api_key.strip
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
