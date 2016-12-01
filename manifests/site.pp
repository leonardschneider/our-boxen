require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}

# Custom

include janus

# Brewcask apps
include brewcask
package {'postman': provider => 'brewcask'}
package {'kindle': provider => 'brewcask'}
package {'amazon-music': provider => 'brewcask'}
package {'cyberduck': provider => 'brewcask'}
package {'steam': provider => 'brewcask'}
package {'skype': provider => 'brewcask'}
package {'google-chrome': provider => 'brewcask'}
package {'tunnelblick': provider => 'brewcask'}
package {'dropbox': provider => 'brewcask'}
package {'macvim': provider => 'brewcask'}
package {'wireshark': provider => 'brewcask'}
package {'xbench': provider => 'brewcask'}
package {'eclipse-java': provider => 'brewcask'}
package {'soapui': provider => 'brewcask'}
package {'java': provider => 'brewcask'}
package {'docker': provider => 'brewcask'}
package {'mactex': provider => 'brewcask'}
package {'firefox': provider => 'brewcask'}
#package {'avira-antivirus': provider => 'brewcask'}

# Brew packages
package {'gcviewer':}
package {'jenv':}
package {'vim':}
package {'maven':}
package {'gradle':}
package {'sbt':}
package {'graphviz':}
package {'ctags':}
package {'cscope':}
package {'fasd':}

