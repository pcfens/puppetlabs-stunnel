# == Define: stunnel::tun
#
# Creates a tunnel config to be started by the stunnel application on startup.
#
# === Parameters
#
# [*namevar*]
#   The namevar in this type is the title you give it when you define a resource
#   instance.  It is used for a handful of purposes; defining the name of the
#   config file and the tunnel section in the config, as well as things like
#   the PID file.
#
# [*certificate*]
#   Signed SSL certificate to be used during authentication and encryption.
#   This module is meant to work in conjuction with an already established
#   Puppet infrastructure so we are defaulting to the default location of the
#   agent certificate on Puppet Enterprise.
#
# [*private_key*]
#   In order to encrypt and decrypt things there needs to be a private_key
#   someplace among the system.  Just like certificate we use data from Puppet
#   Enterprise.
#
# [*ca_file*]
#   The CA to use to validate client certificates.  We default to that
#   distributed by Puppet Enterprise.
#
# [*crl_file*]
#   Currently OCSP is not supported in this module so in order to know if a
#   certificate has not been revoked, you will need to load a revocation list.
#   We default to the one distributed by Puppet Enterprise.
#
# [*ssl_version*]
#   Which SSL version you plan to enforce for this tunnel.  The preferred and
#   default is TLSv1.
#
# [*chroot*]
#   To protect your host the stunnel application runs inside a chrooted
#   environment.  You must devine the location of the processes' root
#   directory.
#
# [*user*]
#   The stunnel application is capable of running each defined tunnel as a
#   different user.
#
# [*group*]
#   The stunnel application is capable of running each defined tunnel as a
#   different group.
#
# [*pid_file*]
#   Where the process ID of the running tunnel is saved.  This values needs to
#   be relative to your chroot directory.
#
# [*debug_level*]
#   The debug leve of your defined tunnels that is sent to the log.
#
# [*log_dest*]
#   The file that log messages are delivered to.
#
# [*client*]
#   If we running our tunnel in client mode.  There is a difference in stunnel
#   between initiating connections or listening for them.
#
# [*accept*]
#   For which host and on which port to accept connection from.
#
# [*connect*]
#  What port or host and port to connect to.
#
# [*conf_dir*]
#   The default base configuration directory for your version on stunnel.
#   By default we look this value up in a stunnel::data class, which has a
#   list of common answers.
#
# [*timeout_busy*]
#   Time to wait for expected data
#
# [*timeout_close*]
#    Time to wait for close_notify (set to 0 for buggy MSIE)
#
# [*timeout_connect*]
#   Time to wait to connect to a remote host
#
# [*timeout_idle*]
#   Time to keep an idle connection
#
# === Examples
#
#   stunnel::tun { 'rsyncd':
#     certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
#     private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
#     ca_file     => '/etc/puppet/ssl/certs/ca.pem',
#     crl_file    => '/etc/puppet/ssl/crl.pem',
#     chroot      => '/var/lib/stunnel4/rsyncd',
#     user        => 'pe-puppet',
#     group       => 'pe-puppet',
#     client      => false,
#     accept      => '1873',
#     connect     => '873',
#   }
#
# === Authors
#
# Cody Herriges <cody@puppetlabs.com>
# Sam Kottler <shk@linux.com>
#
# === Copyright
#
# Copyright 2012 Puppet Labs, LLC
#
define stunnel::tun(
    $certificate,
    $private_key,
    $client,
    $accept,
    $connect,
    $user            = undef,
    $group           = undef,
    $ca_file         = undef,
    $ca_path         = undef,
    $crl_file        = undef,
    $chroot          = undef,
    $timeout_busy    = undef,
    $timeout_close   = undef,
    $timeout_connect = undef,
    $timeout_idle    = undef,
    $ssl_version     = 'TLSv1.2',
    $pid_file        = "/${name}.pid",
    $debug_level     = '0',
    $log_dest        = "/var/log/${name}.log",
    $conf_dir        = $stunnel::params::conf_dir
) {

  $ssl_version_real = $ssl_version ? {
    'tlsv1' => 'TLSv1',
    'sslv2' => 'SSLv2',
    'sslv3' => 'SSLv3',
    default => $ssl_version,
  }

  $client_on = $client ? {
    true  => 'yes',
    false => 'no',
  }

  file { "${conf_dir}/${name}.conf":
    ensure  => file,
    content => template("${module_name}/stunnel.conf.erb"),
    mode    => '0644',
    owner   => '0',
    group   => '0',
    require => File[$conf_dir],
  }

  if $chroot {
    file { $chroot:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0600',
    }
  }
}
