"use client";

import { useState } from "react";
import { updateDeviceThresholdTx } from "@/lib/moveCalls";
import { useSignAndExecuteTransaction } from "@iota/dapp-kit";

export default function UpdateThresholdForm() {
  const [deviceId, setDeviceId] = useState("");
  const [threshold, setThreshold] = useState(500);
  const [status, setStatus] = useState("");

  const { mutateAsync: signAndExecute } = useSignAndExecuteTransaction();

  async function submit() {
    try {
      if (!deviceId.trim()) {
        setStatus("❌ Device ID cannot be empty.");
        return;
      }

      const tx = updateDeviceThresholdTx(deviceId, threshold);
      const result = await signAndExecute(tx);

      setStatus(`✅ Threshold updated. Tx digest: ${result.digest}`);
    } catch (err: any) {
      setStatus(`❌ Error: ${err.message}`);
    }
  }

  return (
    <div className="p-4 border rounded-md mt-6">
      <h2 className="text-xl font-bold mb-3">Update Alert Threshold</h2>

      <input
        className="border p-2 w-full mb-2"
        placeholder="Device Object ID"
        value={deviceId}
        onChange={(e) => setDeviceId(e.target.value)}
      />

      <input
        className="border p-2 w-full mb-2"
        type="number"
        value={threshold}
        min={1}
        onChange={(e) => setThreshold(Number(e.target.value))}
      />

      <button
        onClick={submit}
        className="bg-green-600 text-white px-4 py-2 rounded"
      >
        Update Threshold
      </button>

      {status && <p className="mt-3">{status}</p>}
    </div>
  );
}
