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

## 🖥 **Frontend Setup (Next.js + dApp Kit)**

Go to the frontend directory:

```bash
cd frontend
```

Install dependencies:

```bash
npm install
```

Set your contract IDs in:

```
src/lib/moveConfig.ts
```

Example:

```ts
export const PACKAGE_ID = "0x...";
export const REGISTRY_ID = "0x...";
export const MODULE_NAME = "anti_theft_gps_tracker";
```

Run the local development server:

```bash
npm run dev
```

Open:

```
http://localhost:3000
```

---

## 🎮 **Usage**

### 1. Connect Wallet

Click **Connect Wallet** and allow the connection in your IOTA Wallet extension.

### 2. Create Device

Enter:

* Device name
* Threshold (meters)

Click **Create Device**, approve transaction.

### 3. Update Threshold

Enter:

* Device Object ID
* New threshold

Click **Update Threshold**.

### 4. Send GPS Event

Enter:

* Device Object ID
* Latitude
* Longitude

Click **Send Event**.


## 📂 Project Structure

```
IOTA-WS2025-DAPP/
├── Anti_Theft_GPS_Tracker/     # Move smart contract
│   ├── sources/
│   ├── tests/
│   └── Move.toml
└── frontend/                    # React dApp (Next.js + dApp Kit)
    ├── src/
    │   ├── app/
    │   ├── components/
    │   ├── providers/
    │   └── lib/
    ├── package.json
    └── tailwind.config.js
```


## 📜 License

This project is licensed under the MIT License.


