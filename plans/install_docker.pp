# Installs docker
plan rancher::install_docker(
  TargetSpec $nodes,
) {

  apply_prep($nodes)

  apply($nodes) {
    include ::docker
  }
}
