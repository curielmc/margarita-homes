import { ref, computed } from 'vue'
import api from '../lib/api'
import type { AdminUser } from '../lib/types'

const token = ref<string | null>(localStorage.getItem('admin_token'))
const adminUser = ref<AdminUser | null>(
  JSON.parse(localStorage.getItem('admin_user') || 'null')
)

export function useAuth() {
  const isAuthenticated = computed(() => !!token.value)

  async function login(email: string, password: string) {
    const { data } = await api.post('/admin/sessions', { email, password })
    token.value = data.token
    adminUser.value = data.admin
    localStorage.setItem('admin_token', data.token)
    localStorage.setItem('admin_user', JSON.stringify(data.admin))
    return data
  }

  function logout() {
    token.value = null
    adminUser.value = null
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_user')
  }

  return { token, adminUser, isAuthenticated, login, logout }
}
