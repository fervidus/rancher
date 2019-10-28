#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'puppet'
require 'net/https'
require 'uri'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    uri = URI.parse("https://#{kwargs[:rancher_server]}/v3-public/localProviders/local?action=login")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri, 'Content-type' => 'application/json')
    request.body = { username: 'admin', password: "#{kwargs[:admin_password]}" }.to_json

    response = http.request(request)

    raise Puppet::Error, _("Cannot get login token: #{response.body}") if response.code != '201'

    # Obtain the token
    token = JSON.parse(response.body)['token']

    token.strip
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
