import { fileURLToPath, URL } from "node:url";
import  process from 'process';
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import nodePolyfills from 'rollup-plugin-node-polyfills';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(), 
  ],
  resolve: {
    alias: {

      ...(process.env.NODE_ENV !== 'development'
      ? {
        './runtimeConfig': './runtimeConfig.browser', //fix production build
        stream : 'rollup-plugin-node-polyfills/polyfills/stream',
        util : 'rollup-plugin-node-polyfills/polyfills/util',
      }
      : {
        "@": fileURLToPath(new URL("./src", import.meta.url)),
        util : 'rollup-plugin-node-polyfills/polyfills/util',
      }),
    },
  },
  define: {
    // By default, Vite doesn't include shims for NodeJS/
    // necessary for segment analytics lib to work
    global: {},
  },
  base: ''

});
