Facter.add(:rancher_version) do
  confine kernel: ['Linux']
  setcode do
    rancher_version = nil

    if Facter::Util::Resolution.which('docker')
      rancher_version = Facter::Util::Resolution.exec('docker inspect --format=\'{{println .Config.Image}}\' share-mnt | awk -F: \'{ print $2 }\' 2>&1')
      Facter.debug "Matching image: '#{rancher_version}'"
    end

    rancher_version unless rancher_version.nil?
    #  match = %r{^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*)?(\+[0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*)?$}.match(rancher_version)
    #  unless match.nil?
    #    match[1]
    #  end
    # end
  end
end