class toolbox {
    file {'/usr/local/sbin/puppetsimple.sh':
	owner => root, group => root, mode => "0755",
	content => "#'/bin/sh\npuppet agent --onetime --no-daemonize --verbose $1\n"
    }
}

node 'puppetagent.ec2.internal' {
    include toolbox
    include apache
}

