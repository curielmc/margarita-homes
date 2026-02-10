<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'

const props = defineProps<{ data: { type: string; count: number; avg_price: number }[] }>()
const chartRef = ref<HTMLDivElement>()
let chart: echarts.ECharts | null = null

function renderChart() {
  if (!chartRef.value || !props.data.length) return
  if (!chart) chart = echarts.init(chartRef.value)

  const colors = ['#0d9488', '#0284c7', '#059669', '#f59e0b', '#ef4444', '#8b5cf6']

  chart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: (params: any) => `${params.name}: ${params.value} (${params.percent}%)`,
    },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: true,
      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
      label: { show: true, formatter: '{b}: {c}' },
      data: props.data.map((d, i) => ({
        name: d.type.charAt(0).toUpperCase() + d.type.slice(1),
        value: d.count,
        itemStyle: { color: colors[i % colors.length] },
      })),
    }],
  })
}

onMounted(() => {
  renderChart()
  window.addEventListener('resize', () => chart?.resize())
})
watch(() => props.data, renderChart, { deep: true })
onUnmounted(() => { chart?.dispose(); window.removeEventListener('resize', () => chart?.resize()) })
</script>

<template>
  <div ref="chartRef" class="w-full h-64"></div>
</template>
