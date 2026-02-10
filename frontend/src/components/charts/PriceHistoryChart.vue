<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import type { PriceHistory } from '../../lib/types'

const props = defineProps<{ data: PriceHistory[] }>()
const chartRef = ref<HTMLDivElement>()
let chart: echarts.ECharts | null = null

function renderChart() {
  if (!chartRef.value || !props.data.length) return
  if (!chart) chart = echarts.init(chartRef.value)

  const sorted = [...props.data].sort(
    (a, b) => new Date(a.attributes.recorded_at).getTime() - new Date(b.attributes.recorded_at).getTime()
  )

  const colors: Record<string, string> = {
    asking: '#0d9488',
    reduced: '#f59e0b',
    sold: '#ef4444',
    appraised: '#6366f1',
  }

  chart.setOption({
    tooltip: { trigger: 'axis', valueFormatter: (v: number) => `$${v.toLocaleString()}` },
    xAxis: { type: 'time' },
    yAxis: { type: 'value', axisLabel: { formatter: (v: number) => `$${(v / 1000).toFixed(0)}k` } },
    series: [
      {
        type: 'line',
        smooth: true,
        areaStyle: { opacity: 0.15 },
        data: sorted.map((p) => [p.attributes.recorded_at, Number(p.attributes.price_usd)]),
        itemStyle: {
          color: (params: any) => {
            const idx = params.dataIndex
            const priceType = sorted[idx]?.attributes.price_type as string
            return (priceType && colors[priceType]) || '#0d9488'
          },
        },
        lineStyle: { color: '#0d9488' },
      },
    ],
    grid: { left: 60, right: 20, top: 20, bottom: 30 },
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
