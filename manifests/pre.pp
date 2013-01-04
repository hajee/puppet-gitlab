# Class:: gitlab::pre
#
#
class gitlab::pre {
  include gitlab

  $gitlab_home    = $gitlab::gitlab_home
  $gitlab_user    = $gitlab::gitlab_user
  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_comment    = $gitlab::git_comment
  $gitlab_comment = $gitlab::gitlab_comment




  user {
    $git_user:
      ensure     => present,
      shell      => '/bin/sh',
      home       => $git_home,
      managehome => true,
      comment    => $git_comment,
      system     => true;
    $gitlab_user:
      ensure     => present,
      groups     => $git_user,
      shell      => '/bin/bash',
      home       => $gitlab_home,
      managehome => true,
      comment    => $gitlab_comment,
      require    => User[$git_user];
  }


  file {
    $git_home:
      ensure  => directory,
      owner   => $git_user,
  }


  file {
    $gitlab_home:
      ensure  => directory,
      owner   => $gitlab_user,
  }


  # try and decide about the family here, deal with version/dist specifics within the class
  case $::osfamily {
    'Debian': {
      require gitlab::debian_packages
    }
    'Redhat': {
      require gitlab::redhat_packages
    }
  }
}

class gitlab::redhat_packages {
  include gitlab

  $gitlab_dbtype  = $gitlab::gitlab_dbtype

  Package{ ensure => latest, provider => yum, }
  package {
    [ 'git','wget','curl','redis','openssh-server','python-pip','libicu-devel',
      'libxml2-devel','libxslt-devel','python-devel','libcurl-devel','readline-devel',
      'openssl-devel','zlib-devel','libyaml-devel','postgresql-devel']:
        ensure => installed;
  }

  service { 'redis': ensure => running, enable => true, require => Package['redis'], }

}

class gitlab::debian_packages {
  include gitlab

  $gitlab_dbtype  = $gitlab::gitlab_dbtype
  $git_home       = $gitlab::git_home
  $git_user       = $gitlab::git_user
  $git_admin_pubkey = $gitlab::git_admin_pubkey

  exec {
    'apt-get update':
      command     => '/usr/bin/apt-get update';
  }

  package {
    ['git','wget',
      'openssh-server','python-pip','libicu-dev',
      'python-dev','libpq-dev']:
        ensure  => installed,
        require => Exec['apt-get update'],
  }


  # case $::lsbdistcodename {
  #   # Need to install a fresh ruby version…
  #   'squeeze','precise': {
  #     package {
  #       ['checkinstall','libpq-dev']:
  #         require => Exec['apt-get update'],
  #         ensure  => installed;
  #     }

  #     exec {
  #       'Get Ruby 1.9.3':
  #         command     => 'wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz',
  #         path        => '/usr/sbin:/sbin:/usr/bin:/bin',
  #         cwd         => '/root',
  #         user        => root,
  #         logoutput   => 'on_failure',
  #         unless      => 'test -f /root/ruby-1.9.3-p194.tar.gz';
  #       'Untar Ruby 1.9.3':
  #         command     => 'tar xfz ruby-1.9.3-p194.tar.gz',
  #         path        => '/usr/sbin:/sbin:/usr/bin:/bin',
  #         cwd         => '/root',
  #         user        => root,
  #         require     => Exec['Get Ruby 1.9.3'],
  #         unless      => 'test -d /root/ruby-1.9.3-p194',
  #         logoutput   => 'on_failure',
  #         notify      => Exec['Configure and Install Ruby 1.9.3'];
  #       'Configure and Install Ruby 1.9.3':
  #         command     => '/bin/sh configure && make && make install',
  #         cwd         => '/root/ruby-1.9.3-p194/',
  #         path        => '/usr/sbin:/sbin:/usr/bin:/bin',
  #         user        => root,
  #         timeout     => 900,
  #         require     => Exec['Untar Ruby 1.9.3'],
  #         logoutput   => 'on_failure',
  #         refreshonly => true;
  #     }
  #   } # Squeeze, Precise
  #   default: {
  #     # Assuming default ruby 1.9.3 (wheezy,quantal)
  #     package {
  #       ['ruby','ruby-dev','rubygems','rake']:
  #         require => Exec['apt-get update'],
  #         ensure  => installed;
  #     }
  #   } # Default
  # } # Case:: $::operatingsystem

} # Class:: gitlab::pre
