#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'json'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    cluster_config = {
      "dockerRootDir": "/var/lib/docker",
      "enableNetworkPolicy": false,
      "type": "cluster",
      "rancherKubernetesEngineConfig": {
        "addonJobTimeout": 30,
        "ignoreDockerVersion": true,
        "sshAgentAuth": false,
        "type": "rancherKubernetesEngineConfig",
        "authentication": {
          "type": "authnConfig",
          "strategy": "x509"
        },
        "network": {
          "type": "networkConfig",
          "plugin": "canal"
        },
        "ingress": {
          "type": "ingressConfig",
          "provider": "nginx"
        },
        "monitoring": {
          "type": "monitoringConfig",
          "provider": "metrics-server"
        },
        "services": {
          "type": "rkeConfigServices",
          "kubeApi": {
            "podSecurityPolicy": false,
            "type": "kubeAPIService"
          },
          "etcd": {
            "snapshot": false,
            "type": "etcdService",
            "extraArgs": {
              "heartbeat-interval": 500,
              "election-timeout": 5000
            }
          }
        }
      },
      "name": "#{kwargs[:cluster_name]}"
    }.to_json
  

    uri = URI.parse("https://#{kwargs[:rancher_server]}/v3/cluster")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    request = Net::HTTP::Post.new(uri, 'Content-type' => 'application/json')

    request['Authorization'] = "Bearer #{kwargs[:api_token]}"
    request.body = cluster_config
    
    response = http.request(request)

    raise Puppet::Error, _("Cluster #{kwargs[:cluster_name]} not created: #{response.body}") if response.code != '201'

    cluster_id = JSON.parse(response.body)['id']

    cluster_id.strip
  end
end

MyTask.run if __FILE__ == $0

