plan rancher::wipe_nodes(
  TargetSpec $rancher_server,
  TargetSpec $cluster_controllers,
  TargetSpec $cluster_workers,
) {

  run_task('rancher::cleanup_nodes', $rancher_server)
  run_task('rancher::cleanup_nodes', $cluster_controllers)
  run_task('rancher::cleanup_nodes', $cluster_workers)

}
