source "https://supermarket.chef.io"

cookbook 'nfs', '~> 2.1.0'
cookbook 'apt', '~> 2.9.2'
cookbook 'cron', '~> 1.6.1'
cookbook 'nodejs', '~> 2.4.4'
cookbook 'java', '1.47'
cookbook 'maven', '~> 2.2.0'

# This recipe repo includes a 2nd "cookbook". It extends
# a built-in Opsworks cookbook and overrides the package_ntpd
# recipe. This is a workaround for a buggish thing with
# opsworks and amazon linux. The instructions for how to set
# the time for your Linux instance say to uninstall ntpd
# and install cronyd instead. However, the built-in opsworks
# cookbook insists on installing ntpd during instance setup
# (which conflicts with cronyd. So within this extra cookbook
# we override the ntpd recipe and make it a no-op.
cookbook 'opsworks_initial_setup', path: 'opsworks_initial_setup/'

metadata
