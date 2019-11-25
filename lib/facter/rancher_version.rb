Facter.add(:rancher_version) do
  confine kernel: ['Linux']
  setcode do
    rancher_version = nil

    if Facter::Util::Resolution.which('docker')
      rancher_node_version = Facter::Util::Resolution.exec('docker ps -q -f name=share-mnt && docker inspect --format=\'{{println .Config.Image}}\' share-mnt | awk -F: \'{ print $2 }\' 2>&1')
      rancher_server_env = Facter::Util::Resolution.exec('docker ps -q -f name=rancher && docker inspect --format=\'{{println .Config.Env}}\' rancher 2>&1')
      rancher_server_version = rancher_server_env[/.*CATTLE_AGENT_IMAGE=rancher\/rancher-agent:(v[\d\.]+).*/, 1]
      Facter.debug "Matching image: '#{rancher_node_version}'"
    end

    rancher_node_version unless rancher_node_version.nil?
    rancher_server_version unless rancher_server_version.nil?
    #  match = %r{^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$}.match(rancher_version)
    #  unless match.nil?
    #    match[1]
    #  end
    # end
  end
end