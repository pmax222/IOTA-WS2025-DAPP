"use client";

import ConnectWallet from "@/components/ConnectWallet";
import CreateDeviceForm from "@/components/CreateDeviceForm";
import UpdateThresholdForm from "@/components/UpdateThresholdForm";
import GpsEventForm from "@/components/GpsEventForm";

export default function Page() {
  return (
    <main className="p-10 max-w-2xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Anti-Theft GPS Tracker</h1>

      <ConnectWallet />

      <CreateDeviceForm />
      <UpdateThresholdForm />
      <GpsEventForm />
    </main>
  );
}
