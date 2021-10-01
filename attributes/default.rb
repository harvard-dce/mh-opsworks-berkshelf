
# Maven
default['maven']['version'] = '3.3.9'
default['maven']['setup_bin'] = true
default['maven']['mavenrc']['opts'] = '-Dmaven.repo.local=/root/.m2/repository -Xms1024m -Xmx1024m'

# ActiveMQ
default['activemq']['install_java'] = false
default['activemq']['version'] = '5.15.4'
default['activemq']['transport_protocols'] = 'TLSv1.1,TLSv1.2'
default['activemq']['home'] = '/opt/opencast/activemq'
# this is only to tell the 3rd-party activemq recipe not to issue its own
# service restart; we do that ourselves in the configure-activemq recipe
default['activemq']['enabled'] = false
