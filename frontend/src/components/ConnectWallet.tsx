"use client";

import { ConnectButton } from "@iota/dapp-kit";

export default function ConnectWallet() {
  return (
    <div className="flex justify-center mt-6">
      <ConnectButton />
    </div>
  );
}
