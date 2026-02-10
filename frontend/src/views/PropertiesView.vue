<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../lib/api'
import type { Property, Zone, PaginationMeta } from '../lib/types'
import PropertyCard from '../components/ui/PropertyCard.vue'
import SkeletonLoader from '../components/ui/SkeletonLoader.vue'
import Pagination from '../components/ui/Pagination.vue'

const route = useRoute()
const router = useRouter()
const properties = ref<Property[]>([])
const zones = ref<Zone[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 12 })
const loading = ref(true)

const filters = ref({
  zone_id: (route.query.zone_id as string) || '',
  property_type: (route.query.property_type as string) || '',
  bedrooms_min: (route.query.bedrooms_min as string) || '',
  price_min: (route.query.price_min as string) || '',
  price_max: (route.query.price_max as string) || '',
  page: Number(route.query.page) || 1,
})

async function fetchProperties() {
  loading.value = true
  try {
    const params: any = { page: filters.value.page }
    if (filters.value.zone_id) params.zone_id = filters.value.zone_id
    if (filters.value.property_type) params.property_type = filters.value.property_type
    if (filters.value.bedrooms_min) params.bedrooms_min = filters.value.bedrooms_min
    if (filters.value.price_min) params.price_min = filters.value.price_min
    if (filters.value.price_max) params.price_max = filters.value.price_max

    const { data } = await api.get('/properties', { params })
    properties.value = data.data
    meta.value = data.meta
  } finally {
    loading.value = false
  }
}

function applyFilters() {
  filters.value.page = 1
  updateRoute()
  fetchProperties()
}

function onPageChange(page: number) {
  filters.value.page = page
  updateRoute()
  fetchProperties()
}

function updateRoute() {
  router.replace({ query: { ...filters.value } })
}

function clearFilters() {
  filters.value = { zone_id: '', property_type: '', bedrooms_min: '', price_min: '', price_max: '', page: 1 }
  updateRoute()
  fetchProperties()
}

onMounted(async () => {
  const { data } = await api.get('/zones')
  zones.value = data.data
  fetchProperties()
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">Properties</h1>

    <!-- Filters -->
    <div class="bg-base-100 p-4 rounded-box shadow-sm mb-6">
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
        <select v-model="filters.zone_id" class="select select-bordered select-sm w-full">
          <option value="">All Zones</option>
          <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.attributes.name }}</option>
        </select>
        <select v-model="filters.property_type" class="select select-bordered select-sm w-full">
          <option value="">All Types</option>
          <option value="house">House</option>
          <option value="apartment">Apartment</option>
          <option value="condo">Condo</option>
          <option value="townhouse">Townhouse</option>
          <option value="land">Land</option>
        </select>
        <select v-model="filters.bedrooms_min" class="select select-bordered select-sm w-full">
          <option value="">Bedrooms</option>
          <option value="1">1+</option>
          <option value="2">2+</option>
          <option value="3">3+</option>
          <option value="4">4+</option>
        </select>
        <input v-model="filters.price_min" type="number" placeholder="Min Price" class="input input-bordered input-sm w-full" />
        <input v-model="filters.price_max" type="number" placeholder="Max Price" class="input input-bordered input-sm w-full" />
        <div class="flex gap-2">
          <button @click="applyFilters" class="btn btn-primary btn-sm flex-1">Filter</button>
          <button @click="clearFilters" class="btn btn-ghost btn-sm">Clear</button>
        </div>
      </div>
    </div>

    <p class="text-sm text-base-content/60 mb-4">{{ meta.total_count }} properties found</p>

    <SkeletonLoader v-if="loading" />
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <PropertyCard v-for="prop in properties" :key="prop.id" :property="prop" />
    </div>
    <div v-if="!loading && properties.length === 0" class="text-center py-12 text-base-content/50">
      No properties match your filters.
    </div>

    <Pagination :meta="meta" @page-change="onPageChange" />
  </div>
</template>
