class a2ensite {
	exec { 'a2ensite':
		command => 'sudo a2ensite janipoutaorg.conf',      
                path => '/bin:/usr/bin:/sbin:/usr/sbin:',
        }
	exec { 'a2dissite':
                command => 'sudo a2dissite 000-default.conf',
                path => '/bin:/usr/bin:/sbin:/usr/sbin:',
        }

}
