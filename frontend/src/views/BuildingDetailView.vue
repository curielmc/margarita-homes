<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '../lib/api'
import type { Building, Property } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import PropertyCard from '../components/ui/PropertyCard.vue'
import PropertyMap from '../components/map/PropertyMap.vue'

const route = useRoute()
const { formatCurrency, formatNumber } = useFormatters()
const building = ref<Building | null>(null)
const properties = ref<Property[]>([])
const loading = ref(true)

onMounted(async () => {
  try {
    const { data } = await api.get(`/buildings/${route.params.id}`)
    building.value = data.data
    properties.value = data.included_properties || []
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

    <template v-else-if="building">
      <div class="mb-4">
        <router-link to="/buildings" class="btn btn-ghost btn-sm">&larr; Back to Buildings</router-link>
      </div>

      <!-- Header -->
      <div class="mb-6">
        <h1 class="text-3xl font-bold">{{ building.attributes.name }}</h1>
        <p v-if="building.attributes.address" class="text-base-content/60">{{ building.attributes.address }}</p>
        <router-link :to="`/zones/${building.attributes.zone_slug}`" class="link link-primary text-sm">
          {{ building.attributes.zone_name }}
        </router-link>
      </div>

      <!-- Stat Cards -->
      <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
        <div class="card bg-base-100 shadow-sm p-4 text-center">
          <div class="text-xs text-base-content/50 uppercase">Total Units</div>
          <div class="text-lg font-bold text-primary">{{ building.attributes.total_units ?? 'N/A' }}</div>
        </div>
        <div class="card bg-base-100 shadow-sm p-4 text-center">
          <div class="text-xs text-base-content/50 uppercase">Listed</div>
          <div class="text-lg font-bold text-primary">{{ building.attributes.units_listed }}</div>
        </div>
        <div class="card bg-base-100 shadow-sm p-4 text-center">
          <div class="text-xs text-base-content/50 uppercase">Avg Price</div>
          <div class="text-lg font-bold text-primary">{{ formatCurrency(building.attributes.avg_price) }}</div>
        </div>
        <div class="card bg-base-100 shadow-sm p-4 text-center">
          <div class="text-xs text-base-content/50 uppercase">$/sqft</div>
          <div class="text-lg font-bold text-primary">{{ formatCurrency(building.attributes.avg_price_per_sqft) }}</div>
        </div>
        <div class="card bg-base-100 shadow-sm p-4 text-center">
          <div class="text-xs text-base-content/50 uppercase">Price Range</div>
          <div class="text-sm font-bold text-primary">
            <template v-if="building.attributes.price_range.min">
              {{ formatCurrency(building.attributes.price_range.min) }} - {{ formatCurrency(building.attributes.price_range.max) }}
            </template>
            <template v-else>N/A</template>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Details -->
        <div class="lg:col-span-2">
          <div v-if="building.attributes.description" class="card bg-base-100 shadow-sm p-6 mb-6">
            <h2 class="text-lg font-semibold mb-2">Description</h2>
            <p class="text-base-content/70">{{ building.attributes.description }}</p>
          </div>

          <div class="card bg-base-100 shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-4">Building Details</h2>
            <div class="grid grid-cols-2 gap-3 text-sm">
              <div v-if="building.attributes.year_built">
                <span class="text-base-content/50">Year Built</span>
                <div>{{ building.attributes.year_built }}</div>
              </div>
              <div v-if="building.attributes.floors">
                <span class="text-base-content/50">Floors</span>
                <div>{{ building.attributes.floors }}</div>
              </div>
              <div v-if="building.attributes.total_units">
                <span class="text-base-content/50">Total Units</span>
                <div>{{ formatNumber(building.attributes.total_units) }}</div>
              </div>
              <div v-if="building.attributes.amenities" class="col-span-2">
                <span class="text-base-content/50">Amenities</span>
                <div>{{ building.attributes.amenities }}</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sidebar: Map -->
        <div>
          <div v-if="building.attributes.latitude && building.attributes.longitude" class="card bg-base-100 shadow-sm p-4">
            <h3 class="text-sm font-semibold mb-2">Location</h3>
            <PropertyMap
              :properties="[]"
              :center="[Number(building.attributes.latitude), Number(building.attributes.longitude)]"
              :zoom="15"
            />
          </div>
        </div>
      </div>

      <!-- Properties -->
      <div v-if="properties.length" class="mb-8">
        <h2 class="text-xl font-semibold mb-4">Properties in this Building</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <PropertyCard v-for="property in properties" :key="property.id" :property="property" />
        </div>
      </div>
      <div v-else class="text-center py-10 text-base-content/50">
        No properties currently listed in this building.
      </div>
    </template>
  </div>
</template>
