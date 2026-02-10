<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { Property, PaginationMeta } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'
import Pagination from '../components/ui/Pagination.vue'

const { formatCurrency, statusColor } = useFormatters()
const properties = ref<Property[]>([])
const meta = ref<PaginationMeta>({ current_page: 1, total_pages: 1, total_count: 0, per_page: 12 })
const search = ref('')
const loading = ref(true)

async function fetchProperties(page = 1) {
  loading.value = true
  try {
    const params: any = { page }
    if (search.value) params.search = search.value
    const { data } = await api.get('/admin/properties', { params })
    properties.value = data.data
    meta.value = data.meta
  } finally {
    loading.value = false
  }
}

async function deleteProperty(id: string) {
  if (!confirm('Delete this property?')) return
  await api.delete(`/admin/properties/${id}`)
  fetchProperties(meta.value.current_page)
}

onMounted(() => fetchProperties())
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Properties</h1>
      <router-link to="/admin/properties/new" class="btn btn-primary btn-sm">+ Add Property</router-link>
    </div>

    <div class="flex gap-3 mb-4">
      <input v-model="search" @keyup.enter="fetchProperties(1)" placeholder="Search properties..." class="input input-bordered input-sm flex-1" />
      <button @click="fetchProperties(1)" class="btn btn-sm btn-primary">Search</button>
    </div>

    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <tr>
            <th>Title</th>
            <th>Zone</th>
            <th>Type</th>
            <th>Status</th>
            <th>Price</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="6" class="text-center py-8"><span class="loading loading-spinner"></span></td>
          </tr>
          <tr v-for="prop in properties" :key="prop.id">
            <td>
              <div class="font-semibold">{{ prop.attributes.title }}</div>
              <div class="text-xs text-base-content/50">{{ prop.attributes.address }}</div>
            </td>
            <td>{{ prop.attributes.zone_name }}</td>
            <td class="capitalize">{{ prop.attributes.property_type }}</td>
            <td><span :class="['badge badge-sm', statusColor(prop.attributes.status)]">{{ prop.attributes.status }}</span></td>
            <td>{{ formatCurrency(Number(prop.attributes.current_price_usd)) }}</td>
            <td>
              <div class="flex gap-1">
                <router-link :to="`/admin/properties/${prop.id}/edit`" class="btn btn-ghost btn-xs">Edit</router-link>
                <button @click="deleteProperty(prop.id)" class="btn btn-ghost btn-xs text-error">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <Pagination :meta="meta" @page-change="fetchProperties" />
  </div>
</template>
