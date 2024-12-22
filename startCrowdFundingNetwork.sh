#!/bin/bash

echo "------------Register the CA admin for each organization----------------"

docker compose -f docker/docker-compose-ca.yaml up -d
sleep 3
sudo chmod -R 777 organizations/

echo "------------Register and enroll the users for each organization-----------"

chmod +x registerEnroll.sh
./registerEnroll.sh
sleep 3

echo "------------Build the infrastructure----------------"

docker compose -f docker/docker-compose-4org.yaml up -d
sleep 3

echo "------------Generate the genesis block----------------"

export FABRIC_CFG_PATH=${PWD}/config
export CHANNEL_NAME=cfchannel

# Generate genesis block for the channel
configtxgen -profile FourOrgsChannel -outputBlock ${PWD}/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME

echo "------------Create the application channel------------"

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/msp/tlscacerts/tlsca.crowdfund.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/server.key

osnadmin channel join --channelID $CHANNEL_NAME --config-block ${PWD}/channel-artifacts/$CHANNEL_NAME.block -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2

osnadmin channel list -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2

# Org1 (FundraisersOrg) Peer
export FABRIC_CFG_PATH=${PWD}/peercfg
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=FundraisersMSP
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/users/Admin@fundraisers.crowdfund.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export FUNDRAISERS_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/ca.crt
export DONORS_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/ca.crt
export AUTHORITIES_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/ca.crt
export BANK_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/ca.crt


echo "------------Join Fundraisers peer to the channel------------"
peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 3

echo "------------Update FundraisersOrg anchor peer------------"
peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.FundraisersMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.fundraisers.crowdfund.com","port": 7051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------package chaincode—-------------"

peer lifecycle chaincode package crfund.tar.gz --path ${PWD}/../Chaincode/CrowdFundChain --lang node --label crfund_1.0
sleep 1

echo "—---------------install chaincode in Fundraisers peer—-------------"

peer lifecycle chaincode install crfund.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

export CC_PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid crfund.tar.gz)

echo "------------Approve chaincode in Fundraisers peer------------"

# Approve chaincode for FundraisersMSP
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent

# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 2



# Org2 (DonorsOrg) Peer
export CORE_PEER_LOCALMSPID=DonorsMSP
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/donors.crowdfund.com/users/Admin@donors.crowdfund.com/msp

echo "------------Join Donors peer to the channel------------"
peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1

echo "------------Update DonorsOrg anchor peer------------"
peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.DonorsMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.donors.crowdfund.com","port": 9051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------install chaincode in Donors peer—-------------"

peer lifecycle chaincode install crfund.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

echo "------------Approve chaincode in Donors peer------------"

# Approve chaincode for DonorsMSP
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent

# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 2


# Org3 (AuthoritiesOrg) Peer
export CORE_PEER_LOCALMSPID=AuthoritiesMSP
export CORE_PEER_ADDRESS=localhost:11051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/users/Admin@authorities.crowdfund.com/msp

echo "------------Join Authorities peer to the channel------------"
peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1


echo "------------Update AuthoritiesOrg anchor peer------------"
peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.AuthoritiesMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.authorities.crowdfund.com","port": 11051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------install chaincode in Authorities peer—-------------"

peer lifecycle chaincode install crfund.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

echo "------------Approve chaincode in Authorities peer------------"

# Approve chaincode for AuthoritiesMSP
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent

# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 2

# Org4 (BankOrg) Peer
export CORE_PEER_LOCALMSPID=BankMSP
export CORE_PEER_ADDRESS=localhost:12051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bank.crowdfund.com/users/Admin@bank.crowdfund.com/msp

echo "------------Join Bank peer to the channel------------"
peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1

echo "------------Update BankOrg anchor peer------------"
peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.BankMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.bank.crowdfund.com","port": 12051}]},"version": "0"}}' config_copy.json > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..
peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------install chaincode in Bank peer—-------------"

peer lifecycle chaincode install crfund.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

echo "------------Approve chaincode in Bank peer------------"

# peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 2

# echo "------------Check chaincode commit readiness for CrowdFundChain------------"

peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --sequence 1 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --tls --cafile $ORDERER_CA --output json


# peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --sequence 1 --tls --cafile $ORDERER_CA --output json
sleep 2

# echo "------------Commit chaincode in CrowdFundNetwork------------"

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --sequence 1 --collections-config ../Chaincode/CrowdFundChain/collection-crowdfund.json --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $FUNDRAISERS_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $DONORS_PEER_TLSROOTCERT --peerAddresses localhost:11051 --tlsRootCertFiles $AUTHORITIES_PEER_TLSROOTCERT


# peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.crowdfund.com --channelID $CHANNEL_NAME --name CrowdFundChain --version 1.0 --sequence 1 --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $FUNDRAISERS_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $DONORS_PEER_TLSROOTCERT --peerAddresses localhost:11051 --tlsRootCertFiles $AUTHORITIES_PEER_TLSROOTCERT --peerAddresses localhost:12051 --tlsRootCertFiles $BANK_PEER_TLSROOTCERT
sleep 1

# echo "------------Query committed chaincode for CrowdFundChain------------"

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name CrowdFundChain --cafile $ORDERER_CA



