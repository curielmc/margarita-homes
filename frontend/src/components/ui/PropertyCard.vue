<script setup lang="ts">
import type { Property } from '../../lib/types'
import { useFormatters } from '../../composables/useFormatters'
import PriceBadge from './PriceBadge.vue'

defineProps<{ property: Property }>()
const { formatSqft, statusColor, propertyTypeLabel } = useFormatters()
</script>

<template>
  <router-link :to="`/properties/${property.id}`" class="card bg-base-100 shadow-sm hover:shadow-md transition-shadow">
    <figure class="h-48 overflow-hidden">
      <img
        :src="property.attributes.primary_photo_url || 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800'"
        :alt="property.attributes.title"
        class="w-full h-full object-cover"
      />
    </figure>
    <div class="card-body p-4">
      <div class="flex justify-between items-start">
        <PriceBadge :price="Number(property.attributes.current_price_usd)" />
        <span :class="['badge badge-sm', statusColor(property.attributes.status)]">
          {{ property.attributes.status }}
        </span>
      </div>
      <h3 class="card-title text-sm mt-1">{{ property.attributes.title }}</h3>
      <p class="text-xs text-base-content/60">{{ property.attributes.address }}</p>
      <div class="flex gap-3 text-xs text-base-content/70 mt-2">
        <span v-if="property.attributes.bedrooms">{{ property.attributes.bedrooms }} bd</span>
        <span v-if="property.attributes.bathrooms">{{ property.attributes.bathrooms }} ba</span>
        <span v-if="property.attributes.sqft">{{ formatSqft(Number(property.attributes.sqft)) }}</span>
      </div>
      <div class="flex justify-between items-center mt-2">
        <div class="flex gap-1">
          <span class="badge badge-outline badge-sm">{{ propertyTypeLabel(property.attributes.property_type) }}</span>
          <router-link
            v-if="property.attributes.building_name"
            :to="`/buildings/${property.attributes.building_id}`"
            class="badge badge-primary badge-sm"
            @click.stop
          >{{ property.attributes.building_name }}</router-link>
        </div>
        <div class="flex items-center gap-2">
          <a
            v-if="property.attributes.source_url"
            :href="property.attributes.source_url"
            target="_blank"
            rel="noopener noreferrer"
            class="text-pink-500 hover:text-pink-600 transition-colors"
            title="View on Instagram"
            @click.stop
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
            </svg>
          </a>
          <span class="text-xs text-base-content/50">{{ property.attributes.zone_name }}</span>
        </div>
      </div>
    </div>
  </router-link>
</template>
