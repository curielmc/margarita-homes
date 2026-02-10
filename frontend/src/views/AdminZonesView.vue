<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import type { Zone } from '../lib/types'

const zones = ref<Zone[]>([])
const loading = ref(true)
const showForm = ref(false)
const editingZone = ref<Zone | null>(null)
const form = ref({ name: '', slug: '', description: '', latitude: null as number | null, longitude: null as number | null })

async function fetchZones() {
  loading.value = true
  try {
    const { data } = await api.get('/zones')
    zones.value = data.data
  } finally {
    loading.value = false
  }
}

function startCreate() {
  editingZone.value = null
  form.value = { name: '', slug: '', description: '', latitude: null, longitude: null }
  showForm.value = true
}

function startEdit(zone: Zone) {
  editingZone.value = zone
  form.value = {
    name: zone.attributes.name,
    slug: zone.attributes.slug,
    description: zone.attributes.description || '',
    latitude: zone.attributes.latitude,
    longitude: zone.attributes.longitude,
  }
  showForm.value = true
}

async function save() {
  try {
    if (editingZone.value) {
      await api.patch(`/admin/zones/${editingZone.value.id}`, form.value)
    } else {
      await api.post('/admin/zones', form.value)
    }
    showForm.value = false
    fetchZones()
  } catch (e: any) {
    alert(e.response?.data?.errors?.join(', ') || 'Save failed')
  }
}

async function deleteZone(id: string) {
  if (!confirm('Delete this zone and all its properties?')) return
  await api.delete(`/admin/zones/${id}`)
  fetchZones()
}

onMounted(fetchZones)
</script>

<template>
  <div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Zones</h1>
      <button @click="startCreate" class="btn btn-primary btn-sm">+ Add Zone</button>
    </div>

    <!-- Form Modal -->
    <div v-if="showForm" class="card bg-base-100 shadow-sm p-6 mb-6">
      <h2 class="text-lg font-semibold mb-4">{{ editingZone ? 'Edit' : 'New' }} Zone</h2>
      <form @submit.prevent="save" class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="form-control">
          <label class="label"><span class="label-text">Name</span></label>
          <input v-model="form.name" class="input input-bordered" required />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Slug</span></label>
          <input v-model="form.slug" class="input input-bordered" placeholder="auto-generated if blank" />
        </div>
        <div class="form-control md:col-span-2">
          <label class="label"><span class="label-text">Description</span></label>
          <textarea v-model="form.description" class="textarea textarea-bordered" rows="2"></textarea>
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Latitude</span></label>
          <input v-model.number="form.latitude" type="number" step="0.0000001" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Longitude</span></label>
          <input v-model.number="form.longitude" type="number" step="0.0000001" class="input input-bordered" />
        </div>
        <div class="md:col-span-2 flex gap-2">
          <button type="submit" class="btn btn-primary btn-sm">Save</button>
          <button type="button" @click="showForm = false" class="btn btn-ghost btn-sm">Cancel</button>
        </div>
      </form>
    </div>

    <div class="overflow-x-auto">
      <table class="table table-zebra">
        <thead>
          <tr>
            <th>Name</th>
            <th>Slug</th>
            <th>Description</th>
            <th>Properties</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="5" class="text-center py-8"><span class="loading loading-spinner"></span></td>
          </tr>
          <tr v-for="zone in zones" :key="zone.id">
            <td class="font-semibold">{{ zone.attributes.name }}</td>
            <td class="text-sm text-base-content/60">{{ zone.attributes.slug }}</td>
            <td class="text-sm max-w-xs truncate">{{ zone.attributes.description }}</td>
            <td>{{ zone.attributes.properties_count }}</td>
            <td>
              <div class="flex gap-1">
                <button @click="startEdit(zone)" class="btn btn-ghost btn-xs">Edit</button>
                <button @click="deleteZone(zone.id)" class="btn btn-ghost btn-xs text-error">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
