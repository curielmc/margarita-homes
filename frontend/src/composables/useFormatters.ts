export function useFormatters() {
  function formatCurrency(value: number | null | undefined): string {
    if (value == null) return 'N/A'
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(value)
  }

  function formatNumber(value: number | null | undefined): string {
    if (value == null) return 'N/A'
    return new Intl.NumberFormat('en-US').format(value)
  }

  function formatDate(dateStr: string | null | undefined): string {
    if (!dateStr) return 'N/A'
    return new Date(dateStr).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  }

  function formatSqft(value: number | null | undefined): string {
    if (value == null) return 'N/A'
    return `${formatNumber(Math.round(value))} sq ft`
  }

  function statusColor(status: string): string {
    const colors: Record<string, string> = {
      active: 'badge-success',
      pending: 'badge-warning',
      sold: 'badge-error',
      withdrawn: 'badge-ghost',
    }
    return colors[status] || 'badge-ghost'
  }

  function propertyTypeLabel(type: string): string {
    return type.charAt(0).toUpperCase() + type.slice(1)
  }

  return { formatCurrency, formatNumber, formatDate, formatSqft, statusColor, propertyTypeLabel }
}
