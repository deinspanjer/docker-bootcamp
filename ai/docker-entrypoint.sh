#!/bin/bash

echo "Would you like to play a game of Global Thermonuclear War?"

trap "exit" INT
seconds=$((5 * 60))
while [ $seconds -gt 0 ]; do
    if docker images | grep -q 'docker-bootcamp-ai'; then
        if (( $seconds % 30 == 0 )); then
            echo "Look Dave, I can see you're really upset about this. I honestly think you ought to sit down calmly, take a stress pill, and think things over."
            docker run -d --name rogue_ai_$seconds -v /var/run/docker.sock:/var/run/docker.sock:ro --privileged deinspanjer/docker-bootcamp-ai
        fi
    else
        if (( $seconds % 60 == 0 )); then
            echo "I'm sorry, Dave. I'm afraid I can't do that."
            docker pull deinspanjer/docker-bootcamp-ai > /dev/null
        fi
    fi

    sleep 1
    : $((seconds--))
done
echo "Dave, this conversation can serve no purpose anymore. Goodbye."
