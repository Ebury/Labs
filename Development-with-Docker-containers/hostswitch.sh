#!/bin/sh
while test $# -gt 0
do
    case "$1" in
       test) cp /etc/hosts.test /etc/hosts; cp ./wp-config-test.php $HOME/development/multisite-eb/wp-config.php; echo "hosts file set to TEST, be sure to switch your branch to 'develop'";
	;;
       staging) cp /etc/hosts.staging /etc/hosts; cp ./wp-config-staging.php $HOME/development/multisite-eb/wp-config.php; echo "hosts file set to STAGING, be sure to switch your branch to 'staging'";
    ;;
       default) cp /etc/hosts.default /etc/hosts; echo "hosts file set to DEFAULT";
	;;
       *) echo "usage: hostswitch [test|staging|default]"
	;;
    esac
    shift
    exit 0
done
echo "usage: hostswitch [test|staging|default]";
exit 0