<script setup lang="ts">
import { useFormatters } from '../../composables/useFormatters'

defineProps<{ price: number | null }>()
const { formatCurrency } = useFormatters()
</script>

<template>
  <span class="text-lg font-bold text-primary">{{ formatCurrency(price) }}</span>
</template>
