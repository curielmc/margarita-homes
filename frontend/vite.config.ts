import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['vue', 'vue-router', 'echarts'],
          'charts': ['@/components/charts/MarketTrendChart.vue', '@/components/charts/PropertyTypeChart.vue'],
          'views': [
            '@/views/HomeView.vue', 
            '@/views/PropertiesView.vue', 
            '@/views/MarketTrendsView.vue'
          ]
        }
      }
    },
    chunkSizeWarningLimit: 1000,
    sourcemap: false
  }
})
