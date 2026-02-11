<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import type { MarketSnapshot } from '../../lib/types'

const props = defineProps<{ data: MarketSnapshot[] }>()
const chartRef = ref<HTMLDivElement>()
let chart: echarts.ECharts | null = null

function renderChart() {
  if (!chartRef.value || !props.data.length) return
  if (!chart) chart = echarts.init(chartRef.value)

  const byZone = new Map<string, { dates: string[]; prices: number[] }>()
  for (const s of props.data) {
    if (!s.attributes.price_per_sqft) continue
    const zone = s.attributes.zone_name
    if (!byZone.has(zone)) byZone.set(zone, { dates: [], prices: [] })
    const entry = byZone.get(zone)!
    entry.dates.push(s.attributes.period_start)
    entry.prices.push(s.attributes.price_per_sqft)
  }

  const colors = ['#0d9488', '#0284c7', '#059669', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#6366f1', '#f97316']
  const series = Array.from(byZone.entries()).map(([name, data], i) => ({
    name,
    type: 'line' as const,
    smooth: true,
    data: data.dates.map((d, j) => [d, data.prices[j]]),
    lineStyle: { color: colors[i % colors.length] },
    itemStyle: { color: colors[i % colors.length] },
  }))

  chart.setOption({
    tooltip: { trigger: 'axis', valueFormatter: (v: number) => `$${v.toFixed(0)}/sqft` },
    legend: { type: 'scroll', bottom: 0 },
    xAxis: { type: 'time' },
    yAxis: { type: 'value', axisLabel: { formatter: (v: number) => `$${v.toFixed(0)}` } },
    series,
    grid: { left: 60, right: 20, top: 20, bottom: 50 },
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
  <div ref="chartRef" class="w-full h-80"></div>
</template>
