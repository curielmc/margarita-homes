<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import api from '../lib/api'
import type { Property, PropertyPhoto, PriceHistory } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import PriceBadge from '../components/ui/PriceBadge.vue'
import PriceHistoryChart from '../components/charts/PriceHistoryChart.vue'
import PropertyMap from '../components/map/PropertyMap.vue'

const route = useRoute()
const { formatCurrency, formatDate, formatSqft, statusColor, propertyTypeLabel } = useFormatters()
const property = ref<Property | null>(null)
const photos = ref<PropertyPhoto[]>([])
const priceHistory = ref<PriceHistory[]>([])
const loading = ref(true)
const selectedPhoto = ref(0)

onMounted(async () => {
  try {
    const { data } = await api.get(`/properties/${route.params.id}`)
    property.value = data.data
    photos.value = (data.included || []).filter((i: any) => i.type === 'property_photo')
    priceHistory.value = (data.included || []).filter((i: any) => i.type === 'price_history')
  } finally {
    loading.value = false
  }
})

const currentPhoto = computed(() => {
  if (photos.value.length > 0) return photos.value[selectedPhoto.value]?.attributes.url
  return property.value?.attributes.primary_photo_url || 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'
})
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <div v-if="loading" class="flex justify-center py-20">
      <span class="loading loading-spinner loading-lg"></span>
    </div>

    <template v-else-if="property">
      <div class="mb-4">
        <router-link to="/properties" class="btn btn-ghost btn-sm">&larr; Back to Properties</router-link>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Photos + Details -->
        <div class="lg:col-span-2 space-y-4">
          <!-- Photo Gallery -->
          <div class="card bg-base-100 shadow-sm overflow-hidden">
            <figure class="h-96">
              <img :src="currentPhoto" :alt="property.attributes.title" class="w-full h-full object-cover" />
            </figure>
            <div v-if="photos.length > 1" class="flex gap-2 p-3 overflow-x-auto">
              <button
                v-for="(photo, idx) in photos"
                :key="photo.id"
                @click="selectedPhoto = idx"
                class="w-20 h-16 rounded overflow-hidden border-2 flex-shrink-0"
                :class="idx === selectedPhoto ? 'border-primary' : 'border-transparent'"
              >
                <img :src="photo.attributes.url" class="w-full h-full object-cover" />
              </button>
            </div>
          </div>

          <!-- Description -->
          <div class="card bg-base-100 shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-2">Description</h2>
            <p class="text-base-content/70">{{ property.attributes.description }}</p>
          </div>

          <!-- Price History -->
          <div v-if="priceHistory.length > 0" class="card bg-base-100 shadow-sm p-6">
            <h2 class="text-lg font-semibold mb-4">Price History</h2>
            <PriceHistoryChart :data="priceHistory" class="mb-4" />
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Price</th>
                    <th>Type</th>
                    <th>Notes</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="ph in priceHistory" :key="ph.id">
                    <td>{{ formatDate(ph.attributes.recorded_at) }}</td>
                    <td class="font-semibold">{{ formatCurrency(Number(ph.attributes.price_usd)) }}</td>
                    <td><span class="badge badge-sm badge-outline">{{ ph.attributes.price_type }}</span></td>
                    <td class="text-sm text-base-content/60">{{ ph.attributes.notes }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Sidebar -->
        <div class="space-y-4">
          <div class="card bg-base-100 shadow-sm p-6">
            <PriceBadge :price="Number(property.attributes.current_price_usd)" />
            <h1 class="text-xl font-bold mt-2">{{ property.attributes.title }}</h1>
            <p class="text-base-content/60 text-sm">{{ property.attributes.address }}</p>

            <div class="divider"></div>

            <div class="grid grid-cols-2 gap-3 text-sm">
              <div>
                <span class="text-base-content/50">Status</span>
                <div><span :class="['badge badge-sm', statusColor(property.attributes.status)]">{{ property.attributes.status }}</span></div>
              </div>
              <div>
                <span class="text-base-content/50">Type</span>
                <div>{{ propertyTypeLabel(property.attributes.property_type) }}</div>
              </div>
              <div v-if="property.attributes.bedrooms">
                <span class="text-base-content/50">Bedrooms</span>
                <div>{{ property.attributes.bedrooms }}</div>
              </div>
              <div v-if="property.attributes.bathrooms">
                <span class="text-base-content/50">Bathrooms</span>
                <div>{{ property.attributes.bathrooms }}</div>
              </div>
              <div v-if="property.attributes.sqft">
                <span class="text-base-content/50">Living Area</span>
                <div>{{ formatSqft(Number(property.attributes.sqft)) }}</div>
              </div>
              <div v-if="property.attributes.lot_sqft">
                <span class="text-base-content/50">Lot Size</span>
                <div>{{ formatSqft(Number(property.attributes.lot_sqft)) }}</div>
              </div>
              <div v-if="property.attributes.year_built">
                <span class="text-base-content/50">Year Built</span>
                <div>{{ property.attributes.year_built }}</div>
              </div>
              <div>
                <span class="text-base-content/50">Listed</span>
                <div>{{ formatDate(property.attributes.listed_at) }}</div>
              </div>
            </div>

            <div class="divider"></div>

            <router-link :to="`/zones/${property.attributes.zone_slug}`" class="btn btn-outline btn-sm w-full">
              View {{ property.attributes.zone_name }} Zone
            </router-link>

            <router-link
              v-if="property.attributes.building_id"
              :to="`/buildings/${property.attributes.building_id}`"
              class="btn btn-outline btn-primary btn-sm w-full mt-2"
            >
              View {{ property.attributes.building_name }} Building
            </router-link>

            <!-- Location Map -->
            <div v-if="property.attributes.latitude && property.attributes.longitude" class="mt-4">
              <h3 class="text-sm font-semibold mb-2">Location</h3>
              <PropertyMap
                :properties="[property]"
                :center="[Number(property.attributes.latitude), Number(property.attributes.longitude)]"
                :zoom="14"
              />
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
