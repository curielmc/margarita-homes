<script setup lang="ts">
import type { PaginationMeta } from '../../lib/types'

const props = defineProps<{ meta: PaginationMeta }>()
const emit = defineEmits<{ (e: 'page-change', page: number): void }>()

function goToPage(page: number) {
  if (page >= 1 && page <= props.meta.total_pages) {
    emit('page-change', page)
  }
}
</script>

<template>
  <div v-if="meta.total_pages > 1" class="flex justify-center mt-6">
    <div class="join">
      <button
        class="join-item btn btn-sm"
        :disabled="meta.current_page === 1"
        @click="goToPage(meta.current_page - 1)"
      >
        &laquo;
      </button>
      <template v-for="page in meta.total_pages" :key="page">
        <button
          v-if="page === 1 || page === meta.total_pages || Math.abs(page - meta.current_page) <= 2"
          class="join-item btn btn-sm"
          :class="{ 'btn-active': page === meta.current_page }"
          @click="goToPage(page)"
        >
          {{ page }}
        </button>
        <button
          v-else-if="Math.abs(page - meta.current_page) === 3"
          class="join-item btn btn-sm btn-disabled"
        >
          ...
        </button>
      </template>
      <button
        class="join-item btn btn-sm"
        :disabled="meta.current_page === meta.total_pages"
        @click="goToPage(meta.current_page + 1)"
      >
        &raquo;
      </button>
    </div>
  </div>
</template>
