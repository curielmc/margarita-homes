<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { Zone } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'

const { formatCurrency } = useFormatters()
const zones = ref<Zone[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await api.get('/zones')
    zones.value = data.data
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Zones</h1>
    <p class="text-base-content/60 mb-8">Explore the different zones of Isla de Margarita and their property markets.</p>

    <div v-if="loading" class="flex justify-center py-20">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <router-link
        v-for="zone in zones"
        :key="zone.id"
        :to="`/zones/${zone.attributes.slug}`"
        class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow"
      >
        <div class="card-body">
          <h2 class="card-title text-primary">{{ zone.attributes.name }}</h2>
          <p class="text-sm text-base-content/60 line-clamp-2">{{ zone.attributes.description }}</p>
          <div class="flex justify-between items-center mt-3">
            <span class="text-sm">{{ zone.attributes.properties_count }} properties</span>
            <span v-if="zone.attributes.avg_price" class="font-semibold text-primary">
              {{ formatCurrency(zone.attributes.avg_price) }} avg
            </span>
          </div>
        </div>
      </router-link>
    </div>
  </div>
</template>
