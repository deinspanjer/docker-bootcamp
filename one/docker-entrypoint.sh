#!/bin/bash

postMsg() {
    curl -s --data-urlencode "payload={\"text\": \"$1\"}" https://hooks.slack.com/services/$SLACK/B1WNMBMB2/Ts3mgaEpbUyg2IQRAB8MQL5v >/dev/null
}

postDM() {
    curl -s --data-urlencode "payload={\"channel\":\"@$1\", \"text\": \"$2\"}" https://hooks.slack.com/services/$SLACK/B1WNMBMB2/Ts3mgaEpbUyg2IQRAB8MQL5v >/dev/null
}

if [ -z "$SLACK" ]; then
    echo "ARGH! You didn't run me with the -e SLACK=<special id> environment variable! I can't even phone home to Slack and shame you!  Check the readme and try again, and feel lucky you are getting away with it...  This time!"
    exit 1
fi

declare -A names
for name in arun jim dmitry.skripkin hassan.ashraf manpreet raghav vassim dre; do
    names[$name]=1
done

if [ -z "$NAME" ]; then
    echo "Tsk! You didn't run the Docker image with the -e NAME=<myname> argument.  What a terrible way to start!"
    postMsg "Some unnamed recruit tried to start the Docker container but forgot to tell it their name! -5 points if we figure out who it was!" 
    exit 1
else
    if [[ ${names[$NAME]} ]]; then
        :
    else
        echo "Hmm..  I don't recognize your name.  If you are one of the core team members, please make sure you entered your username exactly as it appears in Slack."
        postMsg "Who the heck is $NAME? I am just a poor dumb bot and I can't guess things very well." 
        exit 1
    fi
fi

if [ -S /var/run/docker.sock ]; then
    :
else
    echo "Tsk! I'm missing something important! there is a hole where a socket should be! Check Slack for more info."
    postMsg "$NAME ran the Docker container but left out an important argument to give it something to which it needs access. -5 points!"
    postDM "$NAME" "Check the <https://docs.docker.com/engine/reference/run/#/volume-shared-filesystems|Docker run command> for the syntax, and maybe try searching Google for ways to run a docker command inside a container. If you are really stuck, ask for help in the #docker-bootcamp channel." 
    exit 1
fi

ip link add dummy0 type dummy >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    # clean the dummy0 link
    ip link delete dummy0 >/dev/null
else
    echo "Sorry, you didn't run me with enough rank and privilege to get my job done.  See the Slack for more info."
    postMsg "$NAME ran the Docker container but forgot an argument that would let the container interact with the host in a privileged manner. -5 points!" 
    postDM "$NAME" "If you need a hint, check the <https://docs.docker.com/engine/reference/run/#/operator-exclusive-options|Operator Exclusive Options> for something to do with Runtime capabilities." 
    exit 1
fi

echo "Congratulations, stage one complete!  Please watch the #docker-bootcamp channel until instructed to press a particular key."
postMsg "$NAME has completed stage one!  Stand by for scoring..."

postMsg "$NAME was able to successfully run the docker-bootcamp-1 image with the necessary arguments, +20 points!"

if docker version | egrep -q 'Version: +1\.1[12]'; then
    postMsg "$NAME is running a recent version of Docker, +20 points!"
else
    postMsg "$NAME is running an older or unrecognized version of Docker, +5 points."
fi

timeSinceHelloWorld=$(docker ps -a | awk 'BEGIN {FS = " {2,}"; matched = 0 } $2 == "hello-world" { matched += 1;  last = $4 } END { print (matched == 0 ? "Never!?" : (matched == 1 ? last : "Multiple times!")) }')
postMsg "$NAME last ran the tutorial's hello-world image: $timeSinceHelloWorld"

timeSinceWhaleSay=$(docker ps -a | awk 'BEGIN {FS = " {2,}"; matched = 0 } $2 == "docker/whalesay" { matched += 1;  last = $4 } END { print (matched == 0 ? "Never!?" : (matched == 1 ? last : "Multiple times!")) }')
postMsg "$NAME last ran the tutorial's whalesay image: $timeSinceWhaleSay"

timeSinceDockerWhale=$(docker images | awk 'BEGIN {FS = " {2,}"; matched = 0 } $1 == "docker-whale" { matched += 1;  last = $4 } END { print (matched == 0 ? "No! :(" : (matched == 1 ? "Yes! "last : "Multiple times!?")) }')
postMsg "$NAME has $(docker images | wc -l) images so far, but do they have the docker-whale image they were supposed to build? $timeSinceDockerWhale"

postMsg "So does $NAME have a good score?  I don't know, Daniel was too tired to make me smart enough to add it all up!"

read input

if [ "$input" == "ai" ]; then
    docker run -d --name rogue_ai_0 -v /var/run/docker.sock:/var/run/docker.sock:ro --privileged deinspanjer/docker-bootcamp-ai
    cat <<-EOM

    I'm sorry to inform you, the AI you just launched has gone rogue.
    We could be in danger of seeing the singularity event and the possible
    extinction of all mankind unless you can manage to kill its running
    containers as well as getting rid of its image so it cannot respawn.

    Open a new shell, and do something about that AI.
    You have five minutes! Good luck, all mankind is depending on you."

EOM

    trap "exit" INT
    seconds=$((5 * 60))
    while [ $seconds -gt 0 ]; do
        if docker images | grep -q 'docker-bootcamp-ai'; then
            if docker ps | grep -q 'rogue_ai'; then
                echo -ne " The AI's image and container still exist. $seconds seconds left\033[0K\r"
            else
                echo -ne " The AI's container is gone, quickly, destroy its image! $seconds seconds left\033[0K\r"
            fi
        else
            if docker ps | grep -q 'rogue_ai'; then
                echo -ne " The AI's image is gone, but one or more containers still exist, destroy them! $seconds seconds left\033[0K\r"
            else
                echo "You've done it! The AI has been eradicated.  Mankind is saved (as long as you don't accidentally run it again...)"
                postMsg "$NAME has defeated the rogue AI! Congratulations on passing day one of docker-bootcamp."
                exit 0
            fi
        fi

        sleep 1
        : $((seconds--))
    done
    echo "What a shame.  The rogue AI took over, and a terminator is on its way to your house right now."
    postMsg "$NAME failed to defeate the rogue AI! They have not passed day one of docker-bootcamp."
else
    echo "You failed to follow directions.  You have flunked out of docker-bootcamp."
    postMsg "$NAME didn't follow directions.  They have flunked out of docker-bootcamp."
fi
