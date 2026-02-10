<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { MarketOverview, MarketSnapshot, Zone, Property } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import StatCard from '../components/ui/StatCard.vue'
import MarketTrendChart from '../components/charts/MarketTrendChart.vue'
import PropertyTypeChart from '../components/charts/PropertyTypeChart.vue'
import ZoneComparisonChart from '../components/charts/ZoneComparisonChart.vue'
import PriceDistributionChart from '../components/charts/PriceDistributionChart.vue'

const { formatCurrency } = useFormatters()
const overview = ref<MarketOverview | null>(null)
const snapshots = ref<MarketSnapshot[]>([])
const zones = ref<Zone[]>([])
const properties = ref<Property[]>([])
const selectedZone = ref('')
const selectedType = ref('')
const loading = ref(true)

async function fetchTrends() {
  const params: any = {}
  if (selectedZone.value) params.zone_id = selectedZone.value
  if (selectedType.value) params.property_type = selectedType.value
  const { data } = await api.get('/market/trends', { params })
  snapshots.value = data.data
}

onMounted(async () => {
  try {
    const [overviewRes, zonesRes, trendsRes, propsRes] = await Promise.all([
      api.get('/market/overview'),
      api.get('/zones'),
      api.get('/market/trends'),
      api.get('/properties', { params: { per_page: 100 } }),
    ])
    overview.value = overviewRes.data.data
    zones.value = zonesRes.data.data
    snapshots.value = trendsRes.data.data
    properties.value = propsRes.data.data
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Market Trends</h1>

    <div v-if="loading" class="flex justify-center py-20">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <template v-else>
      <!-- Overview Stats -->
      <div v-if="overview" class="stats stats-vertical lg:stats-horizontal shadow w-full mb-8">
        <StatCard title="Active Listings" :value="String(overview.total_listings)" />
        <StatCard title="Avg Price" :value="formatCurrency(overview.avg_price)" />
        <StatCard title="Median Price" :value="formatCurrency(overview.median_price)" />
        <StatCard
          title="Price Range"
          :value="`${formatCurrency(overview.price_range.min)} - ${formatCurrency(overview.price_range.max)}`"
        />
      </div>

      <!-- Type Breakdown -->
      <div v-if="overview" class="card bg-base-100 shadow-sm p-6 mb-8">
        <h2 class="text-lg font-semibold mb-4">By Property Type</h2>
        <div class="overflow-x-auto">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>Type</th>
                <th>Count</th>
                <th>Avg Price</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in overview.by_type" :key="item.type">
                <td class="capitalize">{{ item.type }}</td>
                <td>{{ item.count }}</td>
                <td>{{ formatCurrency(item.avg_price) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Charts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div v-if="overview?.by_type" class="card bg-base-100 shadow-sm p-6">
          <h2 class="text-lg font-semibold mb-3">Property Type Distribution</h2>
          <PropertyTypeChart :data="overview.by_type" />
        </div>
        <div v-if="zones.length" class="card bg-base-100 shadow-sm p-6">
          <h2 class="text-lg font-semibold mb-3">Average Price by Zone</h2>
          <ZoneComparisonChart :data="zones" />
        </div>
      </div>

      <div v-if="properties.length" class="card bg-base-100 shadow-sm p-6 mb-8">
        <h2 class="text-lg font-semibold mb-3">Price Distribution</h2>
        <PriceDistributionChart :data="properties" />
      </div>

      <!-- Trend Chart -->
      <div v-if="snapshots.length" class="card bg-base-100 shadow-sm p-6 mb-8">
        <h2 class="text-lg font-semibold mb-3">Price Trends Over Time</h2>
        <MarketTrendChart :data="snapshots" />
      </div>

      <!-- Trend Filters -->
      <div class="flex gap-3 mb-6">
        <select v-model="selectedZone" @change="fetchTrends" class="select select-bordered select-sm">
          <option value="">All Zones</option>
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.attributes.name }}</option>
        </select>
        <select v-model="selectedType" @change="fetchTrends" class="select select-bordered select-sm">
          <option value="">All Types</option>
          <option value="house">House</option>
          <option value="apartment">Apartment</option>
          <option value="condo">Condo</option>
        </select>
      </div>

      <!-- Snapshot Table -->
      <div class="card bg-base-100 shadow-sm p-6">
        <h2 class="text-lg font-semibold mb-4">Monthly Snapshots</h2>
        <div class="overflow-x-auto">
          <table class="table table-sm table-zebra">
            <thead>
              <tr>
                <th>Period</th>
                <th>Zone</th>
                <th>Type</th>
                <th>Avg Price</th>
                <th>Median</th>
                <th>$/sqft</th>
                <th>Listings</th>
                <th>Sold</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="s in snapshots.slice(0, 50)" :key="s.id">
                <td>{{ s.attributes.period_start }}</td>
                <td>{{ s.attributes.zone_name }}</td>
                <td class="capitalize">{{ s.attributes.property_type }}</td>
                <td>{{ formatCurrency(s.attributes.avg_price) }}</td>
                <td>{{ formatCurrency(s.attributes.median_price) }}</td>
                <td>{{ s.attributes.price_per_sqft ? formatCurrency(s.attributes.price_per_sqft) : 'N/A' }}</td>
                <td>{{ s.attributes.listing_count }}</td>
                <td>{{ s.attributes.sold_count }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>
