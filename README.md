# IOTA-WS2025-DAPP
## Anti-Theft GPS Tracker
[ADDRESS_CLIENT_PUBLIC](https://explorer.iota.org/address/0xfccffe70b7a6721785877de0feaa96cac5ec8c3bbf45efb5a28998ed0f5ebdd4?network=testnet)

[ADDRESS_TESTNET](https://explorer.iota.org/address/0x785ecb17d7f625e3835dfbc5104e2c5dbc94a86edcb5565c12eb0ae84d0ec61d?network=testnet)

![Alt Text](https://github.com/pmax222/IOTA-WS2025-DAPP/blob/main/Screenshot%202025-12-10%20201557.png "explorer.iota")

Based on the `Anti_Theft_GPS_Tracker` smart contract and the frontend application we have built, here is a complete, professional **README.md** file in English.

You can create a file named `README.md` in the root folder of your project and paste this content into it.

-----

# Anti-Theft GPS Tracker dApp on IOTA

A decentralized application (dApp) built on the IOTA blockchain that allows users to register GPS devices, track assets, and manage theft reporting transparently on-chain.

## 📋 Overview

This project consists of two main components:

1.  **Smart Contract (Move):** Handles the logic for device creation, asset registration, location updates, and theft status management.
2.  **Frontend (React + IOTA dApp Kit):** A web interface for users to connect their IOTA wallet and interact with the smart contract.

## ✨ Features

  * **Create GPS Device:** Users can register new GPS tracking devices on the blockchain.
  * **Register Assets:** Link physical assets (e.g., Cars, Bikes, Laptops) to a registered GPS device.
  * **Real-time Tracking:** Update and store device geolocation (latitude/longitude) on-chain.
  * **Theft Reporting:** Mark assets as "Stolen" to trigger alerts and status changes.
  * **Recovery:** Mark assets as "Recovered" once found.
  * **Device Management:** Activate or deactivate tracking devices.

## Prerequisites

Before you begin, ensure you have the following installed:

  * [IOTA CLI](https://www.google.com/search?q=https://docs.iota.org/developer/getting-started/install-iota-cli) (for smart contract deployment)
  * [Node.js](https://nodejs.org/) (v18 or higher)
  * [IOTA Wallet](https://www.google.com/search?q=https://chrome.google.com/webstore/detail/iota-wallet/fidafhzcncxmnneodmnkpbnamjxhpjbal) (Browser Extension)

-----

## 🛠️ Setup & Installation

### 1\. Smart Contract Deployment

Navigate to the Move project directory:

```bash
cd Anti_Theft_GPS_Tracker
```

**Build and Test:**

```bash
iota move build
iota move test
```

**Deploy to IOTA Testnet:**
Ensure your CLI is set to testnet and you have gas tokens.

```bash
iota client switch --env testnet
iota client publish --gas-budget 100000000
```

**⚠️ Important:** After deployment, save the **Package ID** and the **Registry ID** (Shared Object) from the output log. You will need these for the frontend.

### 2\. Frontend Setup

Navigate to the frontend directory:

```bash
cd frontend
```

**Install Dependencies:**

```bash
npm install
```

**Configuration:**
Open `src/CreateDevice.tsx` (or your config file) and update the constants with your deployed IDs:

```typescript
const PACKAGE_ID = "0x..."; // Your Package ID
const REGISTRY_ID = "0x..."; // Your Registry ID (Shared Object)
```

**Run the Application:**

```bash
npm run dev
```

Open your browser at `http://localhost:5173`.

-----

## 🚀 Usage Guide

1.  **Connect Wallet:**

      * Open the web app.
      * Click the **"Connect Wallet"** button in the top right corner.
      * Approve the connection in your IOTA Wallet extension.

2.  **Create a Device:**

      * Enter a **Device Name** (e.g., "My Car Tracker").
      * Set an **Alert Threshold** (e.g., 500 meters).
      * Click **"Create Device"** and approve the transaction in your wallet.

3.  **View & Manage:**

      * Once the transaction is confirmed, the device is created on-chain.
      * You can extend the frontend to view your list of devices and register assets to them.

## 📂 Project Structure

```
IOTA-WS2025-DAPP/
├── Anti_Theft_GPS_Tracker/      # Move Smart Contracts
│   ├── sources/                 # Source code (.move files)
│   ├── tests/                   # Unit tests
│   └── Move.toml                # Manifest file
└── frontend/                    # React Web Application
    ├── src/                     # React components
    ├── package.json             # Frontend dependencies
    └── vite.config.ts           # Vite configuration
```

## 📜 License

This project is licensed under the MIT License.

