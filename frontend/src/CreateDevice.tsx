import { useSignAndExecuteTransactionBlock } from "@iota/dapp-kit";
import { Transaction } from "@iota/iota-sdk/transactions";
import { useState } from "react";

// ID PACKAGE và REGISTRY của bạn
const PACKAGE_ID = "0xfccffe70b7a6721785877de0feaa96cac5ec8c3bbf45efb5a28998ed0f5ebdd4"; 
const REGISTRY_ID = "0x0b999b43f2ad7b010a13e71416adf52bdc7827bbe575b318b9d0dbcf6080539b"; 
const MODULE_NAME = "anti_theft_gps_tracker";

export function CreateDevice() {
    // SỬA LỖI 1: Dùng useSignAndExecuteTransactionBlock thay vì useSignAndExecuteTransaction
    const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
    
    const [name, setName] = useState("");
    const [threshold, setThreshold] = useState(1000);

    const createDevice = () => {
        try {
            const tx = new Transaction();

            tx.moveCall({
                target: `${PACKAGE_ID}::${MODULE_NAME}::create_device`,
                arguments: [
                    tx.pure.string(name),
                    tx.pure.u64(threshold),
                    tx.object(REGISTRY_ID),
                ],
            });

            signAndExecute(
                {
                    transactionBlock: tx, // Lưu ý: Tham số này có thể tên là transactionBlock hoặc transaction tùy version, thử transactionBlock trước
                },
                {
                    // SỬA LỖI 2 & 3: Thêm kiểu ': any' để TypeScript không báo lỗi
                    onSuccess: (result: any) => {
                        console.log("Thành công:", result);
                        alert(`Đã tạo thiết bị thành công!\nDigest: ${result.digest}`);
                        setName(""); 
                    },
                    onError: (error: any) => {
                        console.error("Lỗi:", error);
                        alert("Có lỗi xảy ra: " + (error.message || error));
                    },
                }
            );
        } catch (error: any) {
            console.error("Lỗi khởi tạo transaction:", error);
            alert("Lỗi: " + error.message);
        }
    };

    return (
        <div style={{ padding: 20, border: "1px solid #ccc", marginTop: 20, borderRadius: 8 }}>
            <h3>Tạo thiết bị GPS mới</h3>
            <div style={{ marginBottom: 10 }}>
                <label style={{ display: "block", marginBottom: 5 }}>Tên thiết bị:</label>
                <input 
                    type="text" 
                    value={name} 
                    onChange={(e) => setName(e.target.value)} 
                    placeholder="Ví dụ: Xe máy Honda"
                    style={{ padding: 8, width: "100%", boxSizing: "border-box" }}
                />
            </div>
            <div style={{ marginBottom: 10 }}>
                <label style={{ display: "block", marginBottom: 5 }}>Ngưỡng cảnh báo (mét):</label>
                <input 
                    type="number" 
                    value={threshold} 
                    onChange={(e) => setThreshold(Number(e.target.value))}
                    style={{ padding: 8, width: "100%", boxSizing: "border-box" }}
                />
            </div>
            <button 
                onClick={createDevice} 
                style={{ 
                    marginTop: 10, 
                    padding: "10px 20px", 
                    cursor: "pointer", 
                    backgroundColor: "#007bff", 
                    color: "white", 
                    border: "none", 
                    borderRadius: 4 
                }}
            >
                Tạo thiết bị
            </button>
        </div>
    );
}