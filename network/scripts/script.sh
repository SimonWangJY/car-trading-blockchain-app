#!/bin/bash
echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Build Network"
echo

function createChannel(){
echo "Starting create channel..."
CHANNEL_NAME=fancycarchannel
peer channel create -o orderer.fancycar.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/fancycar.com/orderers/orderer.fancycar.com/msp/tlscacerts/tlsca.fancycar.com-cert.pem
}

## Create channel
echo "Create channel fancycarchannel"
createChannel

## Join all the peers to the channel
echo "Join channel"
peer channel join -b fancycarchannel.block

## Install chaincode on Peer0/didi
echo "Installing chaincode"
peer chaincode install -n fancycarcc -v 1.0 -p github.com/chaincode/

# Instantiate chaincode
echo "Instantiate chaincode"
peer chaincode instantiate -o orderer.fancycar.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/fancycar.com/orderers/orderer.fancycar.com/msp/tlscacerts/tlsca.fancycar.com-cert.pem -C fancycarchannel -n fancycarcc -v 1.0 -c '{"Args":["init"]}'

# Invoke chaincode
echo "Init ledger"
sleep 10
peer chaincode invoke -o orderer.fancycar.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/fancycar.com/orderers/orderer.fancycar.com/msp/tlscacerts/tlsca.fancycar.com-cert.pem -C fancycarchannel -n fancycarcc -c '{"function":"initLedger","Args":[""]}'
echo "Create a new car"
peer chaincode invoke -o orderer.fancycar.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/fancycar.com/orderers/orderer.fancycar.com/msp/tlscacerts/tlsca.fancycar.com-cert.pem -C fancycarchannel -n fancycarcc -c '{"function":"createCar","Args":["Car11","BYD","Tang","Black","Simon"]}'

# Network is up
echo
echo "========= All GOOD, FNZ Network up =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo
exit 0