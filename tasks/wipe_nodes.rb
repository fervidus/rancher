#!/opt/puppetlabs/puppet/bin/ruby

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

class MyTask < TaskHelper
  def task(name: nil, **_kwargs)
    cmd_containers_stop = '/usr/bin/sudo /usr/bin/docker ps -a | /usr/bin/awk \'{ print $1 }\' | /usr/bin/grep -v ^CON | while read container; do /usr/bin/sudo /usr/bin/docker stop ${container}; done'
    stdout, stderr, status = Open3.capture3(*cmd_containers_stop) # rubocop:disable Lint/UselessAssignment

    cmd_containers_rm = '/usr/bin/sudo /usr/bin/docker ps -a | /usr/bin/awk \'{ print $1 }\' | /usr/bin/grep -v ^CON | while read container; do /usr/bin/sudo /usr/bin/docker rm ${container}; done'
    stdout, stderr, status = Open3.capture3(*cmd_containers_rm) # rubocop:disable Lint/UselessAssignment

    cmd_images_rm = '/usr/bin/sudo /usr/bin/docker image ls | /usr/bin/awk \'{ print $3 }\' | /usr/bin/grep -v ^IMA | while read image; do /usr/bin/sudo /usr/bin/docker rmi ${image}; done'
    stdout, stderr, status = Open3.capture3(*cmd_images_rm) # rubocop:disable Lint/UselessAssignment

    { stdout: stdout.strip }.to_json
  end
end

MyTask.run if $PROGRAM_NAME == __FILE__
