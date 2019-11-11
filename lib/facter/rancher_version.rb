Facter.add(:rancher_version) do
  confine kernel: ['Linux']
  setcode do
    rancher_version = nil

    if Facter::Util::Resolution.which('docker')
      apache_version = Facter::Util::Resolution.exec('docker inspect --format=\'{{println .Config.Image}}\' share-mnt | awk -F: \'{ print $2 }\' 2>&1')
      Facter.debug "Matching image: '#{rancher_version}'"
    end

    unless rancher_version.nil?
      match = %r{^v\/(\d+.\d+(.\d+)?)}.match(rancher_version)
      unless match.nil?
        match[1]
      end
    end
  end
end
