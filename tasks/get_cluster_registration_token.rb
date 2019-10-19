#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'json'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    uri = URI.parse("https://#{kwargs[:control_plane]}/v3/clusterregistrationtoken")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri, 'Content-type' => 'application/json')

    request['Authorization'] = "Bearer #{kwargs[:api_token]}"
    request.body = { type: 'clusterRegistrationToken', clusterId: kwargs[:cluster_id] }.to_json

    response = http.request(request)

    raise Puppet::Error, _("Cannot get registration token with token #{kwargs[:api_token]}: #{response.body}") if response.code != '201'

    cluster_registration_token = JSON.parse(response.body)['id']
    cluster_registration_token = cluster_registration_token.strip

    uri2 = URI.parse("https://#{kwargs[:control_plane]}/v3/clusterregistrationtoken?id=\"#{cluster_registration_token}\"")
    http2 = Net::HTTP.new(uri2.host, uri2.port)
    http2.use_ssl = true
    http2.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request2 = Net::HTTP::Get.new(uri2, 'Content-type' => 'application/json')

    request2['Authorization'] = "Bearer #{kwargs[:api_token]}"

    response2 = http.request(request2)

    raise Puppet::Error, _("Cannot get join command token with token #{cluster_registration_token}: #{response2.body}") if response2.code != '200'



    join_command = JSON.parse(response2.body)['data']
    # join_command = JSON.parse(response2.body)['nodeCommand']

    join_command[0]['nodeCommand'].strip
    # puts "---#{join_command}---"
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
