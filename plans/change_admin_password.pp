plan rancher::create_cluster_custom(
  TargetSpec $rancher_server,
) {

  $login_token_result_set = run_task('rancher::get_login_token', 'localhost', rancher_server => $rancher_server)
  $login_token = $login_token_result_set.first().message
  out::message("*** login_token: ${login_token}")

  $set_admin_password = run_task('rancher::set_admin_password', 'localhost', rancher_server => $rancher_server, login_token => $login_token, new_password => $new_password)
  $cluster_id = $create_cluster_result_set.first().message
  out::message("*** cluster_id: ${cluster_id}")

}
