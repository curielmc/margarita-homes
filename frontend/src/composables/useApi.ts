import { ref } from 'vue'

export function useApi<T>() {
  const data = ref<T | null>(null) as { value: T | null }
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function execute(fn: () => Promise<T>) {
    loading.value = true
    error.value = null
    try {
      data.value = await fn()
      return data.value
    } catch (e: any) {
      error.value = e.response?.data?.error || e.response?.data?.errors?.join(', ') || e.message
      throw e
    } finally {
      loading.value = false
    }
  }

  return { data, loading, error, execute }
}
