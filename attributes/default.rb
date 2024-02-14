

# Maven
default['maven']['version'] = '3.8.8'
default['maven']['setup_bin'] = true
default['maven']['mavenrc']['opts'] = '-Dmaven.repo.local=/root/.m2/repository -Xms1024m -Xmx1024m'
default['maven']['url'] = "https://#{node.fetch(:shared_asset_bucket_name, 'mh-opsworks-shared-assets')}.s3.amazonaws.com/apache-maven-3.8.8-bin.tar.gz"

# Overrides for nfs
# the nfs cookbook gets these service names wrong for amazon linux 2018.03
# so here we override the nfs cookbook attributes
default['nfs']['service']['lock'] = 'nfslock'
default['nfs']['service']['idmap'] = 'rpcidmapd'
default['nfs']['service']['server'] = 'nfs'
