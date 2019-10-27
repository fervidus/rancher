#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'json'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    uri = URI.parse("https://#{kwargs[:rancher_server]}/v3/settings/server-url")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(uri, 'Content-type' => 'application/json')

    request['Authorization'] = "Bearer #{kwargs[:api_token]}"
    request.body = { name: 'server-url', value: kwargs[:rancher_url] }.to_json

    response = http.request(request)

    raise Puppet::Error, _("Cannot set control plane URL: #{response.body}") if response.code != '200'

    value = JSON.parse(response.body)['value']

    value.strip
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
