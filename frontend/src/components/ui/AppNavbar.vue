<script setup lang="ts">
import { useAuth } from '../../composables/useAuth'
import { useRouter } from 'vue-router'

const { isAuthenticated, logout } = useAuth()
const router = useRouter()

function handleLogout() {
  logout()
  router.push('/')
}
</script>

<template>
  <div class="navbar bg-base-100 shadow-sm">
    <div class="navbar-start">
      <div class="dropdown">
        <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" />
          </svg>
        </div>
        <ul tabindex="0" class="menu menu-sm dropdown-content bg-base-100 rounded-box z-10 mt-3 w-52 p-2 shadow">
          <li><router-link to="/">Home</router-link></li>
          <li><router-link to="/properties">Properties</router-link></li>
          <li><router-link to="/zones">Zones</router-link></li>
          <li><router-link to="/buildings">Buildings</router-link></li>
          <li><router-link to="/market">Market Trends</router-link></li>
        </ul>
      </div>
      <router-link to="/" class="btn btn-ghost text-xl text-primary">Margarita Homes</router-link>
    </div>
    <div class="navbar-center hidden lg:flex">
      <ul class="menu menu-horizontal px-1">
        <li><router-link to="/">Home</router-link></li>
        <li><router-link to="/properties">Properties</router-link></li>
        <li><router-link to="/zones">Zones</router-link></li>
        <li><router-link to="/buildings">Buildings</router-link></li>
        <li><router-link to="/market">Market Trends</router-link></li>
      </ul>
    </div>
    <div class="navbar-end">
      <template v-if="isAuthenticated">
        <router-link to="/admin" class="btn btn-ghost btn-sm">Dashboard</router-link>
        <button @click="handleLogout" class="btn btn-ghost btn-sm">Logout</button>
      </template>
      <router-link v-else to="/admin/login" class="btn btn-ghost btn-sm">Admin</router-link>
    </div>
  </div>
</template>
