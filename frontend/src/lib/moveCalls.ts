import { Transaction } from "@iota/iota-sdk/transactions";
import { PACKAGE_ID, MODULE_NAME, REGISTRY_ID } from "./moveConfig";

// PURE helper
const pure = (value: any, type: string) => ({
  Pure: { value, type },
});

// OBJECT helper
const obj = (id: string) => ({
  ObjectId: id,
});

/* ------------------ CREATE DEVICE ------------------ */
export function createDeviceTx(name: string, threshold: number) {
  const tx = new Transaction();

  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::create_device`,
    arguments: [
      pure(name, "string"),
      pure(threshold, "u64"),
      obj(REGISTRY_ID),
    ],
  });

  return tx;
}

/* ------------------ UPDATE THRESHOLD ------------------ */
export function updateDeviceThresholdTx(deviceId: string, threshold: number) {
  const tx = new Transaction();

  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::update_threshold`,
    arguments: [
      obj(deviceId),
      pure(threshold, "u64"),
    ],
  });

  return tx;
}

/* ------------------ GPS EVENT ------------------ */
export function gpsEventTx(deviceId: string, lat: number, lng: number) {
  const tx = new Transaction();

  tx.moveCall({
    target: `${PACKAGE_ID}::${MODULE_NAME}::register_gps_event`,
    arguments: [
      obj(deviceId),
      pure(lat, "f64"),
      pure(lng, "f64"),
    ],
  });

  return tx;
}
