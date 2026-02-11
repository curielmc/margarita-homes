<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import api from '../lib/api'
import type { Building, Zone } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'

const { formatCurrency } = useFormatters()
const buildings = ref<Building[]>([])
const zones = ref<Zone[]>([])
const selectedZone = ref('')
const loading = ref(true)

async function fetchBuildings() {
  const params: any = {}
  if (selectedZone.value) params.zone_id = selectedZone.value
  const { data } = await api.get('/buildings', { params })
  buildings.value = data.data
}

onMounted(async () => {
  try {
    const [buildingsRes, zonesRes] = await Promise.all([
      api.get('/buildings'),
      api.get('/zones'),
    ])
    buildings.value = buildingsRes.data.data
    zones.value = zonesRes.data.data
  } finally {
    loading.value = false
  }
})

watch(selectedZone, fetchBuildings)
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-2">Buildings</h1>
    <p class="text-base-content/60 mb-6">Browse apartment and condo buildings across Isla de Margarita.</p>

    <!-- Zone Filter -->
    <div class="mb-6">
      <select v-model="selectedZone" class="select select-bordered select-sm">
        <option value="">All Zones</option>
        <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.attributes.name }}</option>
      </select>
    </div>

    <div v-if="loading" class="flex justify-center py-20">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <div v-else-if="buildings.length === 0" class="text-center py-20 text-base-content/50">
      No buildings found.
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <router-link
        v-for="building in buildings"
        :key="building.id"
        :to="`/buildings/${building.id}`"
        class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow"
      >
        <div class="card-body">
          <h2 class="card-title text-primary">{{ building.attributes.name }}</h2>
          <p class="text-sm text-base-content/60">{{ building.attributes.zone_name }}</p>
          <div class="flex flex-wrap gap-2 mt-2">
            <span class="badge badge-outline badge-sm">{{ building.attributes.units_listed }} listed</span>
            <span v-if="building.attributes.total_units" class="badge badge-outline badge-sm">
              {{ building.attributes.total_units }} total units
            </span>
          </div>
          <div class="mt-3 space-y-1 text-sm">
            <div v-if="building.attributes.avg_price" class="flex justify-between">
              <span class="text-base-content/50">Avg Price</span>
              <span class="font-semibold">{{ formatCurrency(building.attributes.avg_price) }}</span>
            </div>
            <div v-if="building.attributes.price_range.min" class="flex justify-between">
              <span class="text-base-content/50">Range</span>
              <span class="font-semibold">
                {{ formatCurrency(building.attributes.price_range.min) }} - {{ formatCurrency(building.attributes.price_range.max) }}
              </span>
            </div>
          </div>
        </div>
      </router-link>
    </div>
  </div>
</template>
