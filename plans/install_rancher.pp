plan rancher::install_rancher(
  TargetSpec $control_plane,
  TargetSpec $workers,
  String[1] $cluster_name = 'fancy-cluster20',
  String[1] $new_password = 'fancy_password',
) {
  # run_plan('rancher::install_docker', $control_plane)
  # run_plan('rancher::install_docker', $workers)
  # run_task('rancher::install_rancher', $control_plane, _catch_errors => true)

  $login_token_result_set = run_task('rancher::get_login_token', 'localhost', control_plane => $control_plane)
  $login_token = $login_token_result_set.first().message

  $api_token_result_set = run_task('rancher::get_api_key', 'localhost', control_plane => $control_plane, login_token => $login_token)
  $api_token = $api_token_result_set.first().message

  $set_url_result_set = run_task('rancher::set_rancher_url', 'localhost', control_plane => $control_plane, rancher_url => 'rancher.fervid.us', api_token => $api_token)

  $create_cluster_result_set = run_task('rancher::create_cluster', 'localhost', control_plane => $control_plane, cluster_name => $cluster_name, api_token => $api_token)
  $cluster_id = $create_cluster_result_set.first().message

  $cluster_join_result_set = run_task('rancher::get_cluster_registration_token', 'localhost', control_plane => $control_plane, cluster_id => $cluster_id, api_token => $api_token)
  $cluster_join_command = $cluster_join_result_set.first().message

  #$server_command_result_set = run_task('exec', $control_plane, command => "${cluster_join_command} --etcd --controlplane")
  #$server_join_status = $server_command_result_set.first().message

  #$worker_command_result_set = run_task('exec', $workers, command => "${cluster_join_command} --worker")
  #$worker_join_status = $worker_command_result_set.first().message

  out::message("***${cluster_join_command}***")
  #out::message("***${join_status}***")
}
