import { ConnectButton, useCurrentAccount } from "@iota/dapp-kit";
import { CreateDevice } from "./CreateDevice";

function App() {
  const account = useCurrentAccount();

  return (
    <div style={{ padding: 40, fontFamily: "sans-serif" }}>
      <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1>IOTA GPS Tracker</h1>
        {/* Nút kết nối ví có sẵn của IOTA */}
        <ConnectButton />
      </header>

      <main style={{ marginTop: 40 }}>
        {!account ? (
          <div style={{ textAlign: "center" }}>
            <h2>Vui lòng kết nối ví để tiếp tục</h2>
          </div>
        ) : (
          <div>
            <p>Xin chào, <strong>{account.address}</strong></p>
            
            {/* Component chức năng */}
            <CreateDevice />
            
          </div>
        )}
      </main>
    </div>
  );
}

export default App;