<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { Property, MarketOverview, Zone, MarketSnapshot } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import StatCard from '../components/ui/StatCard.vue'
import PropertyCard from '../components/ui/PropertyCard.vue'
import SkeletonLoader from '../components/ui/SkeletonLoader.vue'
import PropertyTypeChart from '../components/charts/PropertyTypeChart.vue'
import ZoneComparisonChart from '../components/charts/ZoneComparisonChart.vue'
import MarketTrendChart from '../components/charts/MarketTrendChart.vue'
import PropertyMap from '../components/map/PropertyMap.vue'

const { formatCurrency, formatNumber } = useFormatters()
const overview = ref<MarketOverview | null>(null)
const featured = ref<Property[]>([])
const zones = ref<Zone[]>([])
const trends = ref<MarketSnapshot[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const [overviewRes, propertiesRes, zonesRes, trendsRes] = await Promise.all([
      api.get('/market/overview'),
      api.get('/properties', { params: { featured: 'true', per_page: 6 } }),
      api.get('/zones'),
      api.get('/market/trends', { params: { months: 6 } }),
    ])
    overview.value = overviewRes.data.data
    featured.value = propertiesRes.data.data
    zones.value = zonesRes.data.data
    trends.value = trendsRes.data.data
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div>
    <!-- Hero -->
    <div class="hero min-h-[40vh] bg-gradient-to-br from-primary to-secondary text-primary-content">
      <div class="hero-content text-center">
        <div class="max-w-2xl">
          <h1 class="text-5xl font-bold">Margarita Homes</h1>
          <p class="py-4 text-lg opacity-90">
            Track property prices across Isla de Margarita, Venezuela. Browse listings, compare zones, and follow market trends.
          </p>
          <div class="flex gap-3 justify-center">
            <router-link to="/properties" class="btn btn-accent">Browse Properties</router-link>
            <router-link to="/market" class="btn btn-ghost border-white/30">Market Trends</router-link>
          </div>
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 py-8">
      <!-- Stats -->
      <div v-if="overview" class="stats stats-vertical lg:stats-horizontal shadow w-full mb-8">
        <StatCard title="Active Listings" :value="formatNumber(overview.total_listings)" />
        <StatCard title="Average Price" :value="formatCurrency(overview.avg_price)" />
        <StatCard title="Median Price" :value="formatCurrency(overview.median_price)" />
        <StatCard title="Sold (30 days)" :value="String(overview.total_sold_last_30)" />
        <StatCard title="Zones" :value="String(overview.zones_count)" />
      </div>

      <!-- Featured -->
      <h2 class="text-2xl font-bold mb-4">Featured Properties</h2>
      <SkeletonLoader v-if="loading" :count="6" />
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <PropertyCard v-for="prop in featured" :key="prop.id" :property="prop" />
      </div>
      <div v-if="!loading && featured.length === 0" class="text-center py-8 text-base-content/50">
        No featured properties available.
      </div>

      <div class="text-center mt-8 mb-12">
        <router-link to="/properties" class="btn btn-primary btn-outline">View All Properties</router-link>
      </div>

      <!-- Charts Section -->
      <div v-if="!loading" class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <div v-if="overview?.by_type" class="card bg-base-100 shadow-sm p-6">
          <h3 class="text-lg font-semibold mb-3">Property Types</h3>
          <PropertyTypeChart :data="overview.by_type" />
        </div>
        <div v-if="zones.length" class="card bg-base-100 shadow-sm p-6">
          <h3 class="text-lg font-semibold mb-3">Avg Price by Zone</h3>
          <ZoneComparisonChart :data="zones" />
        </div>
      </div>
      <div v-if="!loading && trends.length" class="card bg-base-100 shadow-sm p-6 mb-8">
        <h3 class="text-lg font-semibold mb-3">Market Trends (6 months)</h3>
        <MarketTrendChart :data="trends" />
      </div>

      <!-- Map -->
      <div v-if="!loading" class="card bg-base-100 shadow-sm p-6 mb-8">
        <h3 class="text-lg font-semibold mb-3">Explore the Island</h3>
        <PropertyMap :zones="zones" :properties="featured" />
      </div>
    </div>
  </div>
</template>
