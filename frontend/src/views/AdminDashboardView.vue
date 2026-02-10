<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { MarketOverview } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import { useAuth } from '../composables/useAuth'
import StatCard from '../components/ui/StatCard.vue'

const { formatCurrency, formatNumber } = useFormatters()
const { adminUser } = useAuth()
const overview = ref<MarketOverview | null>(null)
const loading = ref(true)

async function generateSnapshots() {
  try {
    await api.post('/admin/market_snapshots/generate')
    alert('Market snapshots generated!')
  } catch (e) {
    alert('Failed to generate snapshots')
  }
}

onMounted(async () => {
  try {
    const { data } = await api.get('/market/overview')
    overview.value = data.data
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-3xl font-bold">Admin Dashboard</h1>
        <p class="text-base-content/60">Welcome, {{ adminUser?.name }}</p>
      </div>
    </div>

    <div v-if="overview" class="stats stats-vertical lg:stats-horizontal shadow w-full mb-8">
      <StatCard title="Total Listings" :value="formatNumber(overview.total_listings)" />
      <StatCard title="Avg Price" :value="formatCurrency(overview.avg_price)" />
      <StatCard title="Sold (30d)" :value="String(overview.total_sold_last_30)" />
      <StatCard title="Zones" :value="String(overview.zones_count)" />
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <router-link to="/admin/properties" class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow">
        <div class="card-body items-center text-center">
          <h2 class="card-title">Properties</h2>
          <p class="text-base-content/60">Manage property listings</p>
          <div class="card-actions"><span class="btn btn-primary btn-sm">Manage</span></div>
        </div>
      </router-link>
      <router-link to="/admin/zones" class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow">
        <div class="card-body items-center text-center">
          <h2 class="card-title">Zones</h2>
          <p class="text-base-content/60">Manage zones</p>
          <div class="card-actions"><span class="btn btn-primary btn-sm">Manage</span></div>
        </div>
      </router-link>
      <div class="card bg-base-100 shadow-sm">
        <div class="card-body items-center text-center">
          <h2 class="card-title">Market Snapshots</h2>
          <p class="text-base-content/60">Generate market data</p>
          <div class="card-actions">
            <button @click="generateSnapshots" class="btn btn-primary btn-sm">Generate</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
