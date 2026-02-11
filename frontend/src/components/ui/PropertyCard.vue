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
        <span class="text-xs text-base-content/50">{{ property.attributes.zone_name }}</span>
      </div>
    </div>
  </router-link>
</template>
