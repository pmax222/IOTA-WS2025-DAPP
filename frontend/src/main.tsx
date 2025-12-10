import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";
import "@iota/dapp-kit/dist/index.css";

// SỬA DÒNG NÀY: @iota/sdk -> @iota/iota-sdk
import { getFullnodeUrl } from "@iota/iota-sdk/client";
import { createNetworkConfig, IotaClientProvider, WalletProvider } from "@iota/dapp-kit";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const { networkConfig } = createNetworkConfig({
	testnet: { url: getFullnodeUrl("testnet") },
	localnet: { url: getFullnodeUrl("localnet") },
});

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
	<React.StrictMode>
		<QueryClientProvider client={queryClient}>
			<IotaClientProvider networks={networkConfig} defaultNetwork="testnet">
				<WalletProvider>
					<App />
				</WalletProvider>
			</IotaClientProvider>
		</QueryClientProvider>
	</React.StrictMode>
);