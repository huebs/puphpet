# Class for installing Adminer SQL gui tool
#
# Nginx or Apache must be flagged for installation.
#
class puphpet::adminer {

  include ::puphpet::params
  include ::puphpet::nginx::params
  include ::puphpet::apache::params

  $nginx  = $puphpet::params::hiera['nginx']
  $apache = $puphpet::params::hiera['apache']

  if array_true($nginx, 'install') {
    $webroot = $puphpet::nginx::params::nginx_webroot_location
    $require = Class['puphpet::nginx']
  } elsif array_true($apache, 'install') {
    $webroot = $puphpet::apache::params::default_vhost_dir
    $require = Class['puphpet::apache']
  } else {
    fail('adminer requires either Apache or Nginx installed')
  }

  if ! defined(File[$webroot]) {
    file { $webroot:
      replace => no,
      ensure  => directory,
      mode    => '0775',
    }
  }

  wget::fetch { 'http://www.adminer.org/latest.php':
    cache_dir   => '/var/cache/wget',
    destination => "${webroot}/adminer.php",
    timeout     => 0,
    verbose     => false,
    require     => [
      File[$webroot],
      $require
    ],
  }

}
