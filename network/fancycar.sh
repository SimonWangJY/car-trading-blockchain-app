#!/bin/bash

function clearconfig() {
    # removing data
    echo $PWD
    rm -r crypto-config
    rm -rf channel-artifacts/*.block channel-artifacts/*.tx
    rm -rf fabric-ca-server/fabric-ca-server.db
    cd -

    echo
	echo "clearconfig finished"
}

function generateconfig() {
  echo "generateConfig path"
  cd -

  dir=./channel-artifacts/

  if [[ ! -e $dir ]]; then
      mkdir $dir
  fi
  
  # create certificates and keys
  cryptogen generate --config ./crypto-config.yaml --output=crypto-config
  # create genesis block
  configtxgen -profile FancyCarOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
  # create channel
  configtxgen -profile FancyCarChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID fancycarchannel
  # create anchor peer transactions
  configtxgen -profile FancyCarChannel -outputAnchorPeersUpdate ./channel-artifacts/DidiAnchor.tx -channelID fancycarchannel -asOrg DidiMSP
  configtxgen -profile FancyCarChannel -outputAnchorPeersUpdate ./channel-artifacts/GuaziAnchor.tx -channelID fancycarchannel -asOrg GuaziMSP 
}

function dkcl(){
        CONTAINER_IDS=$(docker ps -aq)
	echo
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "========== No containers available for deletion =========="
        else
                docker rm -f $CONTAINER_IDS
        fi
	echo
}

function dkrm(){
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
	echo
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
	echo
}

function restartnetwork(){
  echo $PWD
  COMPOSE_PROJECT_NAME=artifacts docker-compose -f docker-compose-cli.yaml down --volumes
	dkcl
	dkrm

  #Start the network
	COMPOSE_PROJECT_NAME=artifacts docker-compose -f docker-compose-cli.yaml up -d
}

function stopnetwork(){
  echo
    echo $PWD
    docker-compose -f docker-compose-cli.yaml down --volumes
	  dkcl
	  dkrm
  echo
}

while getopts "h?m:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;    
  esac
done

# Determine whether starting, stopping, restarting or generating for announce
if [ "$MODE" == "go" ]; then
  echo "Starting fancy car network"
  restartnetwork
# Generate certificates and keys
elif [ "$MODE" == "setup" ]; then
  echo "Generating fancy car network"
  clearconfig
  generateconfig
elif [ "$MODE" == "stop" ]; then
  echo "Stop fancy car network"
  stopnetwork
fi
