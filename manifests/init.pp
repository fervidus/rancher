# init.pp
class rancher (
  #
  ) {

  include ::rancher::controller
  include ::rancher::worker

}
