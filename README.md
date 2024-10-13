# CrowdFundingNetwork - Hyperledger Fabric Blockchain Network

This repository sets up a **Hyperledger Fabric** blockchain network for a crowdfunding platform with four organizations: **Fundraisers**, **Donors**, **Authorities**, and **Bank**. The network is configured with Fabric CA for certificate management and includes the full lifecycle of creating a channel, joining peers, and installing chaincode.

## Table of Contents
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Network Setup](#network-setup)
- [Organizations Setup](#organizations-setup)
- [Channel Configuration](#channel-configuration)
- [Chaincode Deployment](#chaincode-deployment)
- [Network Management](#network-management)
- [Useful Commands](#useful-commands)

---

## Architecture

The **CrowdFundingNetwork** consists of the following entities:
- **Orderer Organization**: `crowdfund.com` with one orderer node.
- **Fundraisers Organization**: Includes peers representing fundraising campaigns.
- **Donors Organization**: Includes peers representing donors.
- **Authorities Organization**: Includes peers for regulatory authorities.
- **Bank Organization**: Handles financial transactions.

All organizations use **Fabric CA** for certificate generation and user management. Each organization has one peer node, and the network uses a solo ordering service.

## Prerequisites

Make sure the following tools are installed on your machine:

1. [Docker](https://www.docker.com/)
2. [Docker Compose](https://docs.docker.com/compose/install/)
3. [Node.js](https://nodejs.org/en/) (for running and testing the chaincode)
4. [Hyperledger Fabric binaries](https://hyperledger-fabric.readthedocs.io/en/release-2.2/install.html)

### Clone the Repository

```bash
git clone https://github.com/yourusername/CrowdFundingNetwork.git
cd CrowdFundingNetwork
