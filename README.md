** This is an example of using Puppet: **
* There are two nodes: master and agent
* Two manifests exist on the master:
  - site.pp will create puppetsimple.sh on the agent if doesn't exist
  - apache.pp will install apache if not there

**Pre-requisites**

1. Two Linux boxes hosted, say, by AWS (console.aws.amazon.com) with some descriptive names like: 
* become root: ```sudo su -```
* ```hostname puppetagent.example.org```
* ```hostname puppetmaster2.example.org```

2. They are added to each other /etc/hosts, e.g.:
* on the agent: ```echo 172.31.62.149 puppetmaster2.example.org >> /etc/hosts```
* on the master: ```echo 172.31.58.139 puppetagent.example.org >> /etc/hosts```

3. Puppet 4+ software is installed for root on both hosts:
* ```gem install puppet```

4. Plug-in folder(s) are created on the master: 
At least one folder should be created with facts.d sub-folder in it:
/etc/puppetlabs/code/environments/production/modules/moduleA/facts.d/

Note: otherwise it fails, which is a known bug.

5. Puppet configs created - /etc/puppetlabs/puppet/puppet.conf:
* agent: 
```
[main]
server=puppetmaster2.example.org
```
* master: 
```
[master]
sertname=puppetmaster2.example.org
ca_server=puppetmaster2.example.org
```
6. SSL certificates generated and signed off: 
* run the master: ```puppet master --no-daemonize --verbose --user root --group root```
* run the agent: ```puppet agent --no-daemonize --onetime --verbose```
* stop the master and sign off the agent certificate: ```puppet cert sign puppetagent.ec2.internal```

**Manifests**

1. Create two sample manifests on the master - /etc/puppetlabs/code/environments/production/manifests/:
* site.pp - to create puppetsimple.sh:
```
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
```
* apache.pp to install apache: 
```
class apache {
    package { 'httpd':
	ensure => installed
    }
}
```
**Running**
* on the master: ```puppet master --no-daemonize --verbose --user root --group root```
* on the agent: ```puppet agent --onetime --no-daemonize --verbose```

Once the agent is over:
* /usr/local/sbin/puppetsimple.sh with 755 permissions will be created if didn't exist
* apache will be installed if not there
