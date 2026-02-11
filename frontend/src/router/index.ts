import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/HomeView.vue'),
    },
    {
      path: '/properties',
      name: 'properties',
      component: () => import('../views/PropertiesView.vue'),
    },
    {
      path: '/properties/:id',
      name: 'property-detail',
      component: () => import('../views/PropertyDetailView.vue'),
    },
    {
      path: '/zones',
      name: 'zones',
      component: () => import('../views/ZonesView.vue'),
    },
    {
      path: '/zones/:slug',
      name: 'zone-detail',
      component: () => import('../views/ZoneDetailView.vue'),
    },
    {
      path: '/buildings',
      name: 'buildings',
      component: () => import('../views/BuildingsView.vue'),
    },
    {
      path: '/buildings/:id',
      name: 'building-detail',
      component: () => import('../views/BuildingDetailView.vue'),
    },
    {
      path: '/market',
      name: 'market-trends',
      component: () => import('../views/MarketTrendsView.vue'),
    },
    {
      path: '/admin/login',
      name: 'admin-login',
      component: () => import('../views/AdminLoginView.vue'),
    },
    {
      path: '/admin',
      name: 'admin-dashboard',
      component: () => import('../views/AdminDashboardView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/admin/properties',
      name: 'admin-properties',
      component: () => import('../views/AdminPropertiesView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/admin/properties/new',
      name: 'admin-property-new',
      component: () => import('../views/AdminPropertyFormView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/admin/properties/:id/edit',
      name: 'admin-property-edit',
      component: () => import('../views/AdminPropertyFormView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/admin/zones',
      name: 'admin-zones',
      component: () => import('../views/AdminZonesView.vue'),
      meta: { requiresAuth: true },
    },
  ],
})

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !localStorage.getItem('admin_token')) {
    return { name: 'admin-login' }
  }
})

export default router
