<script setup lang="ts">
defineProps<{
  title: string
  value: string
  description?: string
}>()
</script>

<template>
  <div class="stat bg-base-100 rounded-box shadow-sm">
    <div class="stat-title">{{ title }}</div>
    <div class="stat-value text-primary text-2xl">{{ value }}</div>
    <div v-if="description" class="stat-desc">{{ description }}</div>
  </div>
</template>
