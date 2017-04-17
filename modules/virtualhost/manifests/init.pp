class virtualhost {
	package { 'apache2':
		ensure => 'installed',
		allowcdrom => 'true',
	}
	file { '/etc/apache2/sites-available/janipoutaorg.conf':
		content => template('virtualhost/janipoutaorg.conf.erb'),
		notify => Service['apache2'], 
	}
	file { '/etc/hosts':
		content => template('virtualhost/hosts.erb'),
		notify => Service['apache2'],
	}
	file { '/home/xubuntu/public_html':
        	ensure => 'directory',
        }    
    	file { '/home/xubuntu/public_html/index.html':
        	content => template('virtualhost/index.html.erb'),
        	require => File['/home/xubuntu/public_html'],
	}
	service { 'apache2':
		ensure => 'true',
		enable => 'true',
		provider => 'systemd',
	}
}
