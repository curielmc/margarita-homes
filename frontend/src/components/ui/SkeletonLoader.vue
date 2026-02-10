<script setup lang="ts">
defineProps<{ count?: number }>()
</script>

<template>
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <div v-for="i in (count || 6)" :key="i" class="card bg-base-100 shadow-sm">
      <div class="skeleton h-48 w-full"></div>
      <div class="card-body p-4 gap-2">
        <div class="skeleton h-4 w-20"></div>
        <div class="skeleton h-4 w-full"></div>
        <div class="skeleton h-3 w-3/4"></div>
        <div class="flex gap-2 mt-2">
          <div class="skeleton h-3 w-12"></div>
          <div class="skeleton h-3 w-12"></div>
          <div class="skeleton h-3 w-16"></div>
        </div>
      </div>
    </div>
  </div>
</template>
