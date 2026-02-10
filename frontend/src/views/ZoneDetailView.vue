<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '../lib/api'
import type { Zone, Property, PaginationMeta } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import PropertyCard from '../components/ui/PropertyCard.vue'
import StatCard from '../components/ui/StatCard.vue'
import Pagination from '../components/ui/Pagination.vue'

const route = useRoute()
const { formatCurrency } = useFormatters()
const zone = ref<Zone | null>(null)
const properties = ref<Property[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 12 })
const loading = ref(true)

async function fetchProperties(page = 1) {
  const { data } = await api.get('/properties', { params: { zone_id: zone.value?.id, page } })
  properties.value = data.data
  meta.value = data.meta
}

onMounted(async () => {
  try {
    const { data } = await api.get(`/zones/${route.params.slug}`)
    zone.value = data.data
    await fetchProperties()
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <div v-if="loading" class="flex justify-center py-20">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <template v-else-if="zone">
      <div class="mb-4">
        <router-link to="/zones" class="btn btn-ghost btn-sm">&larr; Back to Zones</router-link>
      </div>

      <h1 class="text-3xl font-bold mb-2">{{ zone.attributes.name }}</h1>
      <p class="text-base-content/60 mb-6">{{ zone.attributes.description }}</p>

      <div class="stats stats-vertical md:stats-horizontal shadow mb-8 w-full">
        <StatCard title="Properties" :value="String(zone.attributes.properties_count)" />
        <StatCard title="Avg Price" :value="formatCurrency(zone.attributes.avg_price)" />
      </div>

      <h2 class="text-xl font-semibold mb-4">Properties in {{ zone.attributes.name }}</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <PropertyCard v-for="prop in properties" :key="prop.id" :property="prop" />
      </div>
      <div v-if="properties.length === 0" class="text-center py-8 text-base-content/50">
        No properties listed in this zone.
      </div>

      <Pagination :meta="meta" @page-change="fetchProperties" />
    </template>
  </div>
</template>
