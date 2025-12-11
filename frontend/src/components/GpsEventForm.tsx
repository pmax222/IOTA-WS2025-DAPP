"use client";

import { useState } from "react";
import { gpsEventTx } from "@/lib/moveCalls";
import { useSignAndExecuteTransaction } from "@iota/dapp-kit";

export default function GpsEventForm() {
  const [deviceId, setDeviceId] = useState("");
  const [lat, setLat] = useState(0);
  const [lng, setLng] = useState(0);
  const [status, setStatus] = useState("");

  const { mutateAsync: signAndExecute } = useSignAndExecuteTransaction();

  async function sendEvent() {
    try {
      const tx = gpsEventTx(deviceId, lat, lng);
      const result = await signAndExecute(tx);

      setStatus(`GPS event sent! Tx digest: ${result.digest}`);
    } catch (err: any) {
      setStatus(`❌ Error: ${err.message}`);
    }
  }

  return (
    <div className="p-4 border rounded-md mt-6">
      <h2 className="text-xl font-bold mb-3">Send GPS Event</h2>

      <input
        className="border p-2 w-full mb-2"
        placeholder="Device Object ID"
        value={deviceId}
        onChange={(e) => setDeviceId(e.target.value)}
      />

      <input
        className="border p-2 w-full mb-2"
        placeholder="Latitude"
        type="number"
        value={lat}
        onChange={(e) => setLat(Number(e.target.value))}
      />

      <input
        className="border p-2 w-full mb-2"
        placeholder="Longitude"
        type="number"
        value={lng}
        onChange={(e) => setLng(Number(e.target.value))}
      />

      <button
        onClick={sendEvent}
        className="bg-purple-600 text-white px-4 py-2 rounded"
      >
        Send Event
      </button>

      {status && <p className="mt-3">{status}</p>}
    </div>
  );
}
