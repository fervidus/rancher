plan rancher::create_cluster_custom(
  TargetSpec $rancher_server,
  TargetSpec $cluster_controllers,
  TargetSpec $cluster_workers,
  String[1] $cluster_name = 'default-cluster',
  String[1] $admin_password = 'admin',
) {
  $login_token_result_set = run_task('rancher::get_login_token', 'localhost', rancher_server => $rancher_server, admin_password => $admin_password )
  $login_token = $login_token_result_set.first().message
  # out::message("*** login_token: ${login_token}")

  $api_token_result_set = run_task('rancher::get_api_key', 'localhost', rancher_server => $rancher_server, login_token => $login_token)
  $api_token = $api_token_result_set.first().message
  # out::message("*** api_token: ${api_token}")

  $set_url_result_set = run_task('rancher::set_rancher_url', 'localhost', rancher_server => $rancher_server, rancher_url => "https://${rancher_server}", api_token => $api_token)

  $create_cluster_result_set = run_task('rancher::create_cluster_custom', 'localhost', rancher_server => $rancher_server, cluster_name => $cluster_name, api_token => $api_token)
  $cluster_id = $create_cluster_result_set.first().message
  # out::message("*** cluster_id: ${cluster_id}")

  $cluster_join_result_set = run_task('rancher::get_cluster_registration_token', 'localhost', rancher_server => $rancher_server, cluster_id => $cluster_id, api_token => $api_token)
  $cluster_join_command = $cluster_join_result_set.first().message
  # out::message("*** cluster_join_command: ${cluster_join_command}")

  $controller_join_command_result_set = run_task('exec', $cluster_controllers, command => "${cluster_join_command} --etcd --controlplane")

  $controller_join_statuses = $controller_join_command_result_set.map | $controller_join_result | {
    $node = $controller_join_result.target.name

    if $controller_join_result.ok {
      "${node} returned a value: ${controller_join_result.message}"
    } else {
      "${node} errored with a message: ${controller_join_result.error.message}"
    }
  }

  # $controller_join_status = $controller_join_command_result_set.first().message
  # out::message("*** controller_join_status: ${controller_join_status}")

  $worker_join_command_result_set = run_task('exec', $cluster_workers, command => "${cluster_join_command} --worker")


  $worker_join_statuses = $worker_join_command_result_set.map | $worker_join_result | {
    $node = $worker_join_result.target.name

    if $worker_join_result.ok {
      "${node} returned a value: ${worker_join_result.message}"
    } else {
      "${node} errored with a message: ${worker_join_result.error.message}"
    }
  }

  # $worker_join_status = $worker_join_command_result_set.first().message
  # out::message("*** worker_join_status: ${worker_join_status}")

  $plan_results = {
    login_token              => $login_token,
    api_token                => $api_token,
    cluster_id               => $cluster_id,
    controller_join_statuses => $controller_join_statuses,
    worker_join_statuses     => $worker_join_statuses,
  }

  return $plan_results
}
