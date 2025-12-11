import "./globals.css";
import { AppProviders } from "@/providers/AppProviders";

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
