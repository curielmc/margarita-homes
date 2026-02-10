<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import type { Property, Zone } from '../../lib/types'
import { useFormatters } from '../../composables/useFormatters'

const props = defineProps<{
  properties?: Property[]
  zones?: Zone[]
  center?: [number, number]
  zoom?: number
}>()

const { formatCurrency } = useFormatters()
const mapRef = ref<HTMLDivElement>()
let map: L.Map | null = null
let markerLayer: L.LayerGroup | null = null

// Fix Leaflet default marker icon
delete (L.Icon.Default.prototype as any)._getIconUrl
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
})

function updateMarkers() {
  if (!map || !markerLayer) return
  markerLayer.clearLayers()

  if (props.properties) {
    for (const p of props.properties) {
      const lat = Number(p.attributes.latitude)
      const lng = Number(p.attributes.longitude)
      if (!lat || !lng) continue

      const marker = L.marker([lat, lng])
      marker.bindPopup(`
        <div style="min-width:150px">
          <strong>${p.attributes.title}</strong><br/>
          <span style="color:#0d9488;font-weight:bold">${formatCurrency(Number(p.attributes.current_price_usd))}</span><br/>
          <small>${p.attributes.zone_name}</small><br/>
          <a href="/properties/${p.id}" style="color:#0284c7">View details</a>
        </div>
      `)
      markerLayer.addLayer(marker)
    }
  }

  if (props.zones) {
    for (const z of props.zones) {
      const lat = Number(z.attributes.latitude)
      const lng = Number(z.attributes.longitude)
      if (!lat || !lng) continue

      const circle = L.circle([lat, lng], {
        radius: 1500,
        color: '#0d9488',
        fillColor: '#0d9488',
        fillOpacity: 0.1,
        weight: 2,
      })
      circle.bindPopup(`
        <div>
          <strong>${z.attributes.name}</strong><br/>
          <small>${z.attributes.properties_count} properties</small><br/>
          <a href="/zones/${z.attributes.slug}" style="color:#0284c7">View zone</a>
        </div>
      `)
      markerLayer.addLayer(circle)
    }
  }
}

onMounted(() => {
  if (!mapRef.value) return

  map = L.map(mapRef.value).setView(props.center || [11.0, -63.9], props.zoom || 11)
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; OpenStreetMap contributors',
  }).addTo(map)

  markerLayer = L.layerGroup().addTo(map)
  updateMarkers()
})

watch(() => [props.properties, props.zones], updateMarkers, { deep: true })
onUnmounted(() => { map?.remove() })
</script>

<template>
  <div ref="mapRef" class="w-full h-96 rounded-box overflow-hidden"></div>
</template>
