<script setup lang="ts">
import AppNavbar from './components/ui/AppNavbar.vue'
</script>

<template>
  <div class="min-h-screen bg-base-200">
    <AppNavbar />
    <router-view />
  </div>
</template>
