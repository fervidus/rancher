plan rancher::create_cluster_custom(
  TargetSpec $rancher_server,
  String[1] $current_password = 'admin',
  String[1] $new_password,
) {

  $login_token_result_set = run_task('rancher::get_login_token', 'localhost', rancher_server => $rancher_server)
  $login_token = $login_token_result_set.first().message
  out::message("*** login_token: ${login_token}")

  $set_admin_password_resault_set = run_task('rancher::set_admin_password', 'localhost', rancher_server => $rancher_server, login_token => $login_token, current_password => $current_password, new_password => $new_password)
  $set_admin_password_result = $set_admin_password_result_set.first().message
  out::message("*** set_admin_password_result: ${set_admin_password_result}")

}
