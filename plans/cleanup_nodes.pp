plan rancher::install_rancher(
  TargetSpec $control_plane,
  TargetSpec $workers,
) {

  run_task('rancher::create_cluster', $control_plane)
  run_task('rancher::create_cluster', $workers)


}
