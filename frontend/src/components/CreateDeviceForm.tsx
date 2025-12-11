"use client";

import { useState } from "react";
import { createDeviceTx } from "@/lib/moveCalls";
import { useSignAndExecuteTransaction } from "@iota/dapp-kit";

export default function CreateDeviceForm() {
  const [name, setName] = useState("");
  const [threshold, setThreshold] = useState(1000);
  const [status, setStatus] = useState("");

  const { mutateAsync: signAndExecute } = useSignAndExecuteTransaction();

  async function submit() {
    try {
      const tx = createDeviceTx(name, threshold);

      const result = await signAndExecute(tx);

      setStatus(`Device created! Digest: ${result.digest}`);
    } catch (err: any) {
      setStatus(`❌ Error: ${err.message}`);
    }
  }

  return (
    <div className="p-4 border rounded-md mt-4">
      <h2 className="text-xl font-bold mb-3">Create GPS Device</h2>

      <input
        className="border p-2 w-full mb-2"
        placeholder="Device Name"
        value={name}
        onChange={e => setName(e.target.value)}
      />

      <input
        type="number"
        className="border p-2 w-full mb-2"
        placeholder="Threshold"
        value={threshold}
        onChange={e => setThreshold(Number(e.target.value))}
      />

      <button
        onClick={submit}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        Create Device
      </button>

      {status && <p className="mt-3">{status}</p>}
    </div>
  );
}
