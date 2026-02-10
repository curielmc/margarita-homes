<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import type { Property } from '../../lib/types'

const props = defineProps<{ data: Property[] }>()
const chartRef = ref<HTMLDivElement>()
let chart: echarts.ECharts | null = null

function renderChart() {
  if (!chartRef.value || !props.data.length) return
  if (!chart) chart = echarts.init(chartRef.value)

  const buckets = [
    { label: '<$50k', min: 0, max: 50000 },
    { label: '$50k-100k', min: 50000, max: 100000 },
    { label: '$100k-200k', min: 100000, max: 200000 },
    { label: '$200k-350k', min: 200000, max: 350000 },
    { label: '$350k-500k', min: 350000, max: 500000 },
    { label: '$500k+', min: 500000, max: Infinity },
  ]

  const counts = buckets.map((b) =>
    props.data.filter((p) => {
      const price = Number(p.attributes.current_price_usd)
      return price >= b.min && price < b.max
    }).length
  )

  chart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: { type: 'category', data: buckets.map((b) => b.label) },
    yAxis: { type: 'value' },
    series: [{
      type: 'bar',
      data: counts,
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#0d9488' },
          { offset: 1, color: '#059669' },
        ]),
        borderRadius: [4, 4, 0, 0],
      },
    }],
    grid: { left: 40, right: 20, top: 20, bottom: 30 },
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
