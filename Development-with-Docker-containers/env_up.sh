#!/bin/sh
#set folder where the repository is located (no trailing slash)
RPLOCATION="/Users/[[yourname]]/development/[[website]]"
#which DB version of the Docker image you want to use
DBVERSION="1.0.5"
#which VM version of the Docker image you want to use
VMVERSION="1.4.8"


# Important:
# Most docker commands are run against marcebury account with docker images (eg marcebury/test), 
# you should replace this with your docker username, and docker image names.
#
# Also the names given to the docker images start with Ebury (eg. EburyVM), you should change
# this also to the names you decide to give to your images.
#
# inspect the code carefully to replace this to match your naming rules
function checkContainer() {
  
    EXISTS="false"
    RUNNING=$(docker inspect --format="{{ .State.Running }}" Ebury$1 2> /dev/null)
    if [[ $RUNNING == "false" || $RUNNING == "true" ]]
      then
        EXISTS="true"
    fi
    
    if [ $EXISTS == "false" ]
        then
        # Container does not exist, so we run it; if the image doesn't exist then it will be downloaded and started
        case "$1" in
            DB)
                OP=$(docker run --name "EburyDB" -it -p 3306:3306 -p 81:80 -d marcebury/eburyvmdb:$2 /bin/bash -c "/etc/init.d/apache2 restart; /usr/bin/mysqld_safe")
                ;;
            VM)
                OP=$(docker run --privileged --name "EburyVM" -p 80:80 -d -v $3:/var/www/html marcebury/test:$2 /usr/sbin/apache2ctl -D FOREGROUND)
                ;;
            *)
                ;;
        esac
        echo "$1 Container version $2 created and started"
    else
        IMAGE=$(docker inspect --format="{{ .Config.Image }}" Ebury$1)
        VERSION=(${IMAGE//:/ }); VERSION=${VERSION[1]}
        
        # Container exists
        if [[ $RUNNING == "true" && $VERSION == $2 ]]
            then
                # Container has the expected version and is already running, no change needed
                echo "$1 Container $2 is already running."
        fi
    
        if [[ $RUNNING == "true" && $VERSION != $2 ]]
            then
                # Container is running but doesn't have the expected version
                # we ask if this is expected
                read -p "You are running a $1 Container, but it is not the expected version, we will update the $1 Container but this will re-initialize it to it's default state. Data may be lost!! Are you sure? " REPLY
            
                if [[ $REPLY =~ ^[Yy]$ ]]
                    then
                        #user agrees, so we stop Container, remove the Container, and run the new version
                        OP=$(docker stop Ebury$1)
                        OP=$(docker rm Ebury$1)
                        case "$1" in
                            DB)
                                OP=$(docker run --name "EburyDB" -it -p 3306:3306 -p 81:80 -d marcebury/eburyvmdb:$2 /bin/bash -c "/etc/init.d/apache2 restart; /usr/bin/mysqld_safe")
                                ;;
                            VM)
                                OP=$(docker run --privileged --name "EburyVM" -p 80:80 -d -v $3:/var/www/html marcebury/test:$2 /usr/sbin/apache2ctl -D FOREGROUND)
                                ;;
                            *)
                                ;;
                        esac
                        echo "$1 Container updated and now running version $2"
                fi
        fi
    
        if [[ $RUNNING == "false" && $VERSION == $2 ]]
            then
                # Container is not running, but has the correct version, so we start the Container
                OP=$(docker start Ebury$1 2> /dev/null)
                echo "$1 Container $2 started."
        fi
    
        if [[ $RUNNING == "false" && $VERSION != $2 ]]
            then
                # Container is not running, and doesn't have the correct version
                read -p "A $1 Container exists but is not running, and it is not the expected version, we will update the $1 Container but this will re-initialize it to it's default state. Data may be lost!! Are you sure? " REPLY
        
                if [[ $REPLY =~ ^[Yy]$ ]]
                    then
                        #user agrees, so we stop Container, remove the Container, and run the new version
                        OP=$(docker stop Ebury$1)
                        OP=$(docker rm Ebury$1)
                        case "$1" in
                            DB)
                                OP=$(docker run --name "EburyDB" -it -p 3306:3306 -p 81:80 -d marcebury/eburyvmdb:$2 /bin/bash -c "/etc/init.d/apache2 restart; /usr/bin/mysqld_safe")
                                ;;
                            VM)
                                OP=$(docker run --privileged --name "EburyVM" -p 80:80 -d -v $3:/var/www/html marcebury/test:$2 /usr/sbin/apache2ctl -D FOREGROUND)
                                ;;
                            *)
                                ;;
                        esac
                fi
        fi
    
    fi
}

# check for DB container and start up the requested version
checkContainer DB $DBVERSION 
# check for VM container and start up the requested version
checkContainer VM $VMVERSION $RPLOCATION

echo "Mounting S3 filesystem in /mnt/s3mount"

# sleep for 3 seconds, just the give the EburyVM container a bit of time to fire up completly. Just in case.
sleep 3

# grab the container id of the EburyVM container
CONT=$(docker ps -a | grep -F 'EburyVM' | sed -e 's/^\(.\{12\}\).*/\1/')
# execute the s3 bucket mounting line on the EburyVM Container
OP=$(docker exec $CONT s3fs -o allow_other -o use_cache=/tmp [[name_of_your_s3_bucket]] /mnt/s3mount)


exit 1