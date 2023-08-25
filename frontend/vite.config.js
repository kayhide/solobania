import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import htmlPlugin from "vite-plugin-html-config";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    htmlPlugin({
      metas: [{ name: "BASE_URL", content: process.env.BASE_URL }],
    }),
  ],

  server: {
    host: "0.0.0.0",
    port: process.env.APP_HTTP_PORT || "3000",
    proxy: {
      "/api": "http://rails:3000",
      "/rails": "http://rails:3000",
    },
  },
});
