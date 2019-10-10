#!/opt/puppetlabs/puppet/bin/ruby
require 'open3'
require 'json'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **kwargs)
    # Change the password
    change_cmd = "curl -s 'https://#{kwargs[:control_plane]}/v3/users?action=changepassword' -H 'content-type: application/json' -H \"Authorization: Bearer #{kwargs[:login_token]}\" --data-binary '{\"currentPassword\":\"admin\",\"newPassword\":\"#{kwargs[:new_password]}\"}' --insecure"
    y_stdout, y_stderr, y_status = Open3.capture3(*change_cmd) # rubocop:disable Lint/UselessAssignment
    raise Puppet::Error, _("stderr: ' #{y_stderr}') % { stderr: y_stderr }") if status != 0

    y_stdout.strip
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
