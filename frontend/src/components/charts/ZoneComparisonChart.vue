<script setup lang="ts">
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'
import type { Zone } from '../../lib/types'

const props = defineProps<{ data: Zone[] }>()
const chartRef = ref<HTMLDivElement>()
let chart: echarts.ECharts | null = null

function renderChart() {
  if (!chartRef.value || !props.data.length) return
  if (!chart) chart = echarts.init(chartRef.value)

  const sorted = [...props.data]
    .filter((z) => z.attributes.avg_price)
    .sort((a, b) => Number(a.attributes.avg_price) - Number(b.attributes.avg_price))

  chart.setOption({
    tooltip: { trigger: 'axis', valueFormatter: (v: number) => `$${v.toLocaleString()}` },
    xAxis: { type: 'value', axisLabel: { formatter: (v: number) => `$${(v / 1000).toFixed(0)}k` } },
    yAxis: { type: 'category', data: sorted.map((z) => z.attributes.name) },
    series: [{
      type: 'bar',
      data: sorted.map((z) => Number(z.attributes.avg_price)),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#059669' },
          { offset: 1, color: '#0d9488' },
        ]),
        borderRadius: [0, 4, 4, 0],
      },
    }],
    grid: { left: 120, right: 30, top: 10, bottom: 20 },
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
