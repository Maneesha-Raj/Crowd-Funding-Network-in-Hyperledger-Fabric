#!/bin/bash

function createFundraisers() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/fundraisers.crowdfund.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-fundraisers --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fundraisers.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fundraisers.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fundraisers.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-fundraisers.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/config.yaml"

  # Copy fundraisers CA cert to the necessary directories
  mkdir -p "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/tlsca/tlsca.fundraisers.crowdfund.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/ca"
  cp "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/ca/ca.fundraisers.crowdfund.com-cert.pem"

  # Registering peer0
  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-fundraisers --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Registering peer1
  echo "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-fundraisers --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-fundraisers --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-fundraisers --id.name fundraisersadmin --id.secret fundraisersadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Enrolling peer0
  echo "Generating the peer0 MSP"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/msp/config.yaml"

  echo "Generating the peer0 TLS certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls" --enrollment.profile tls --csr.hosts peer0.fundraisers.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer0.fundraisers.crowdfund.com/tls/server.key"

  # Enrolling peer1
  echo "Generating the peer1 MSP"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/msp/config.yaml"

  echo "Generating the peer1 TLS certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls" --enrollment.profile tls --csr.hosts peer1.fundraisers.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/peers/peer1.fundraisers.crowdfund.com/tls/server.key"

  echo "Generating the user MSP"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/users/User1@fundraisers.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/users/User1@fundraisers.crowdfund.com/msp/config.yaml"

  echo "Generating the org admin MSP"
  set -x
  fabric-ca-client enroll -u https://fundraisersadmin:fundraisersadminpw@localhost:7054 --caname ca-fundraisers -M "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/users/Admin@fundraisers.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/fundraisers/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/fundraisers.crowdfund.com/users/Admin@fundraisers.crowdfund.com/msp/config.yaml"
}

function createDonors() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/donors.crowdfund.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/donors.crowdfund.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-donors --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-donors.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-donors.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-donors.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-donors.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy donors's CA cert to donors's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/donors/ca-cert.pem" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/tlscacerts/ca.crt"

  # Copy donors's CA cert to donors's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/donors/ca-cert.pem" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/tlsca/tlsca.donors.crowdfund.com-cert.pem"

  # Copy donors's CA cert to donors's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/ca"
  cp "${PWD}/organizations/fabric-ca/donors/ca-cert.pem" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/ca/ca.donors.crowdfund.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-donors --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-donors --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-donors --id.name donorsadmin --id.secret donorsadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-donors -M "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-donors -M "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls" --enrollment.profile tls --csr.hosts peer0.donors.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/peers/peer0.donors.crowdfund.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-donors -M "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/users/User1@donors.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/users/User1@donors.crowdfund.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://donorsadmin:donorsadminpw@localhost:8054 --caname ca-donors -M "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/users/Admin@donors.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/donors/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/donors.crowdfund.com/users/Admin@donors.crowdfund.com/msp/config.yaml"
}

function createAuthorities() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/authorities.crowdfund.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-authorities --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-authorities.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-authorities.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-authorities.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-authorities.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy authorities's CA cert to authorities's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/tlscacerts/ca.crt"

  # Copy authorities's CA cert to authorities's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/tlsca/tlsca.authorities.crowdfund.com-cert.pem"

  # Copy authorities's CA cert to authorities's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/ca"
  cp "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/ca/ca.authorities.crowdfund.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-authorities --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-authorities --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-authorities --id.name authoritiesadmin --id.secret authoritiesadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-authorities -M "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-authorities -M "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls" --enrollment.profile tls --csr.hosts peer0.authorities.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/peers/peer0.authorities.crowdfund.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-authorities -M "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/users/User1@authorities.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/users/User1@authorities.crowdfund.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://authoritiesadmin:authoritiesadminpw@localhost:11054 --caname ca-authorities -M "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/users/Admin@authorities.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/authorities/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/authorities.crowdfund.com/users/Admin@authorities.crowdfund.com/msp/config.yaml"
}

function createBank() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/bank.crowdfund.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/bank.crowdfund.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-bank --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-bank.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-bank.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-bank.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-bank.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy bank's CA cert to bank's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/bank/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/tlscacerts/ca.crt"

  # Copy bank's CA cert to bank's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/bank/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/tlsca/tlsca.bank.crowdfund.com-cert.pem"

  # Copy bank's CA cert to bank's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/ca"
  cp "${PWD}/organizations/fabric-ca/bank/ca-cert.pem" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/ca/ca.bank.crowdfund.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-bank --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-bank --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bank --id.name bankadmin --id.secret bankadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-bank -M "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/msp/config.yaml"

  echo "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-bank -M "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls" --enrollment.profile tls --csr.hosts peer0.bank.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/peers/peer0.bank.crowdfund.com/tls/server.key"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:12054 --caname ca-bank -M "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/users/User1@bank.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/users/User1@bank.crowdfund.com/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://bankadmin:bankadminpw@localhost:12054 --caname ca-bank -M "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/users/Admin@bank.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bank/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bank.crowdfund.com/users/Admin@bank.crowdfund.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/crowdfund.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/crowdfund.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/crowdfund.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/crowdfund.com/msp/tlscacerts/tlsca.crowdfund.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/crowdfund.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/crowdfund.com/tlsca/tlsca.crowdfund.com-cert.pem"

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/msp/config.yaml"

  echo "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls" --enrollment.profile tls --csr.hosts orderer.crowdfund.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/crowdfund.com/orderers/orderer.crowdfund.com/msp/tlscacerts/tlsca.crowdfund.com-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/crowdfund.com/users/Admin@crowdfund.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/crowdfund.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/crowdfund.com/users/Admin@crowdfund.com/msp/config.yaml"
}

createFundraisers
createDonors
createAuthorities
createBank
createOrderer
