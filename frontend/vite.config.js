import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
    plugins: [vue()],
    server: {
        allowedHosts: ['rupture-unjustly-worst.ngrok-free.dev']
    }
})
