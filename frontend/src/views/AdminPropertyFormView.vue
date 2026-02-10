<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '../lib/api'
import type { Zone, PriceHistory } from '../lib/types'
import { useFormatters } from '../composables/useFormatters'

const route = useRoute()
const router = useRouter()
const { formatCurrency, formatDate } = useFormatters()
const isEdit = computed(() => !!route.params.id)
const zones = ref<Zone[]>([])
const priceHistories = ref<PriceHistory[]>([])
const saving = ref(false)
const error = ref('')

const form = ref({
  zone_id: '',
  title: '',
  address: '',
  property_type: 'house',
  status: 'active',
  bedrooms: null as number | null,
  bathrooms: null as number | null,
  sqft: null as number | null,
  lot_sqft: null as number | null,
  year_built: null as number | null,
  description: '',
  current_price_usd: null as number | null,
  listed_at: '',
  sold_at: '',
  featured: false,
  latitude: null as number | null,
  longitude: null as number | null,
})

const newPrice = ref({ price_usd: null as number | null, price_type: 'asking', recorded_at: '', notes: '' })

async function save() {
  saving.value = true
  error.value = ''
  try {
    if (isEdit.value) {
      await api.patch(`/admin/properties/${route.params.id}`, form.value)
    } else {
      await api.post('/admin/properties', form.value)
    }
    router.push('/admin/properties')
  } catch (e: any) {
    error.value = e.response?.data?.errors?.join(', ') || 'Save failed'
  } finally {
    saving.value = false
  }
}

async function addPriceHistory() {
  if (!newPrice.value.price_usd || !newPrice.value.recorded_at) return
  try {
    await api.post(`/admin/properties/${route.params.id}/price_histories`, newPrice.value)
    newPrice.value = { price_usd: null, price_type: 'asking', recorded_at: '', notes: '' }
    await loadProperty()
  } catch (e: any) {
    alert(e.response?.data?.errors?.join(', ') || 'Failed to add price')
  }
}

async function loadProperty() {
  const { data } = await api.get(`/admin/properties/${route.params.id}`)
  const attrs = data.data.attributes
  form.value = {
    zone_id: data.data.relationships.zone.data.id,
    title: attrs.title,
    address: attrs.address || '',
    property_type: attrs.property_type,
    status: attrs.status,
    bedrooms: attrs.bedrooms,
    bathrooms: attrs.bathrooms ? Number(attrs.bathrooms) : null,
    sqft: attrs.sqft ? Number(attrs.sqft) : null,
    lot_sqft: attrs.lot_sqft ? Number(attrs.lot_sqft) : null,
    year_built: attrs.year_built,
    description: attrs.description || '',
    current_price_usd: attrs.current_price_usd ? Number(attrs.current_price_usd) : null,
    listed_at: attrs.listed_at || '',
    sold_at: attrs.sold_at || '',
    featured: attrs.featured,
    latitude: attrs.latitude ? Number(attrs.latitude) : null,
    longitude: attrs.longitude ? Number(attrs.longitude) : null,
  }
  priceHistories.value = (data.included || []).filter((i: any) => i.type === 'price_history')
}

onMounted(async () => {
  const { data } = await api.get('/zones')
  zones.value = data.data
  if (isEdit.value) await loadProperty()
})
</script>

<template>
  <div class="container mx-auto px-4 py-8 max-w-3xl">
    <div class="mb-4">
      <router-link to="/admin/properties" class="btn btn-ghost btn-sm">&larr; Back</router-link>
    </div>

    <h1 class="text-3xl font-bold mb-6">{{ isEdit ? 'Edit' : 'New' }} Property</h1>

    <div v-if="error" class="alert alert-error mb-4"><span>{{ error }}</span></div>

    <form @submit.prevent="save" class="card bg-base-100 shadow-sm p-6 space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="form-control md:col-span-2">
          <label class="label"><span class="label-text">Title</span></label>
          <input v-model="form.title" class="input input-bordered" required />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Zone</span></label>
          <select v-model="form.zone_id" class="select select-bordered" required>
            <option value="">Select zone</option>
            <option v-for="z in zones" :key="z.id" :value="z.id">{{ z.attributes.name }}</option>
          </select>
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Type</span></label>
          <select v-model="form.property_type" class="select select-bordered">
            <option value="house">House</option>
            <option value="apartment">Apartment</option>
            <option value="condo">Condo</option>
            <option value="townhouse">Townhouse</option>
            <option value="land">Land</option>
            <option value="commercial">Commercial</option>
          </select>
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Status</span></label>
          <select v-model="form.status" class="select select-bordered">
            <option value="active">Active</option>
            <option value="pending">Pending</option>
            <option value="sold">Sold</option>
            <option value="withdrawn">Withdrawn</option>
          </select>
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Price (USD)</span></label>
          <input v-model.number="form.current_price_usd" type="number" class="input input-bordered" />
        </div>
        <div class="form-control md:col-span-2">
          <label class="label"><span class="label-text">Address</span></label>
          <input v-model="form.address" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Bedrooms</span></label>
          <input v-model.number="form.bedrooms" type="number" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Bathrooms</span></label>
          <input v-model.number="form.bathrooms" type="number" step="0.5" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Sqft</span></label>
          <input v-model.number="form.sqft" type="number" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Year Built</span></label>
          <input v-model.number="form.year_built" type="number" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Listed Date</span></label>
          <input v-model="form.listed_at" type="date" class="input input-bordered" />
        </div>
        <div class="form-control">
          <label class="label"><span class="label-text">Sold Date</span></label>
          <input v-model="form.sold_at" type="date" class="input input-bordered" />
        </div>
        <div class="form-control md:col-span-2">
          <label class="label"><span class="label-text">Description</span></label>
          <textarea v-model="form.description" class="textarea textarea-bordered" rows="3"></textarea>
        </div>
        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-3">
            <input v-model="form.featured" type="checkbox" class="checkbox checkbox-primary" />
            <span class="label-text">Featured</span>
          </label>
        </div>
      </div>

      <button type="submit" class="btn btn-primary" :disabled="saving">
        <span v-if="saving" class="loading loading-spinner loading-sm"></span>
        {{ saving ? 'Saving...' : (isEdit ? 'Update' : 'Create') }} Property
      </button>
    </form>

    <!-- Price History (edit mode only) -->
    <div v-if="isEdit" class="card bg-base-100 shadow-sm p-6 mt-6">
      <h2 class="text-lg font-semibold mb-4">Price History</h2>

      <div class="flex gap-2 mb-4 flex-wrap">
        <input v-model.number="newPrice.price_usd" type="number" placeholder="Price" class="input input-bordered input-sm w-32" />
        <select v-model="newPrice.price_type" class="select select-bordered select-sm">
          <option value="asking">Asking</option>
          <option value="reduced">Reduced</option>
          <option value="sold">Sold</option>
          <option value="appraised">Appraised</option>
        </select>
        <input v-model="newPrice.recorded_at" type="date" class="input input-bordered input-sm" />
        <input v-model="newPrice.notes" placeholder="Notes" class="input input-bordered input-sm flex-1" />
        <button @click="addPriceHistory" class="btn btn-sm btn-primary">Add</button>
      </div>

      <table v-if="priceHistories.length" class="table table-sm">
        <thead>
          <tr><th>Date</th><th>Price</th><th>Type</th><th>Notes</th></tr>
        </thead>
        <tbody>
          <tr v-for="ph in priceHistories" :key="ph.id">
            <td>{{ formatDate(ph.attributes.recorded_at) }}</td>
            <td>{{ formatCurrency(Number(ph.attributes.price_usd)) }}</td>
            <td><span class="badge badge-sm badge-outline">{{ ph.attributes.price_type }}</span></td>
            <td>{{ ph.attributes.notes }}</td>
          </tr>
        </tbody>
      </table>
      <p v-else class="text-sm text-base-content/50">No price history entries yet.</p>
    </div>
  </div>
</template>
