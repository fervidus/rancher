#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **_kwargs)
    cmd = 'sudo docker run -d --mount source=rancher,target=/var/lib/rancher --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher --name rancher'
    stdout, stderr, status = Open3.capture3(*cmd) # rubocop:disable Lint/UselessAssignment
    # raise Puppet::Error, _("stderr: ' #{stderr}') % { stderr: stderr }") if status != 0

    { stdout: stdout.strip }.to_json
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
