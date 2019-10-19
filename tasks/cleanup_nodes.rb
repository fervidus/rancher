#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **_kwargs)
    cmd_containers_stop = 'sudo docker ps -a | awk \'{ print $1 }\' grep -v ^CON | while read container; do sudo docker stop ${container}; done'
    stdout, stderr, status = Open3.capture3(*cmd_containers_stop) # rubocop:disable Lint/UselessAssignment

    cmd_containers_rm = 'sudo docker ps -a | awk \'{ print $1 }\' grep -v ^CON | while read container; do sudo docker rm ${container}; done'
    stdout, stderr, status = Open3.capture3(*cmd_containers_rm) # rubocop:disable Lint/UselessAssignment

    cmd_images_rm = 'sudo docker image ls | awk \'{ print $3 }\' grep -v ^IMA | while read image; do sudo docker rmi ${image}; done'
    stdout, stderr, status = Open3.capture3(*cmd_images_rm) # rubocop:disable Lint/UselessAssignment

    # raise Puppet::Error, _("stderr: ' #{stderr}') % { stderr: stderr }") if status != 0

    { stdout: stdout.strip }.to_json
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
