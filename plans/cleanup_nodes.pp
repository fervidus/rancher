plan rancher::cleanup_nodes(
  TargetSpec $control_plane,
  TargetSpec $workers,
) {

  run_task('rancher::cleanup_nodes', $control_plane)
  run_task('rancher::cleanup_nodes', $workers)


}
