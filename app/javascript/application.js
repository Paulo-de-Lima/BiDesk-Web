import "@hotwired/turbo-rails"

const toggleDashboardLoading = (isLoading) => {
  const dashboardRoot = document.querySelector("[data-dashboard-root]")
  if (!dashboardRoot) return
  dashboardRoot.dataset.loading = isLoading ? "true" : "false"
  dashboardRoot
    .querySelectorAll(".dashboard-card-skeleton")
    .forEach((el) => el.classList.toggle("hidden", !isLoading))
  dashboardRoot
    .querySelectorAll(".dashboard-card-content")
    .forEach((el) => el.classList.toggle("opacity-0", isLoading))
}

document.addEventListener("turbo:before-fetch-request", (event) => {
  if (!document.querySelector("[data-dashboard-root]")) return
  const detail = event.detail || {}
  const headers =
    detail.fetchOptions?.headers ||
    detail.fetchRequest?.headers ||
    detail.request?.headers
  const getHeader = (name) => {
    if (!headers) return null
    if (typeof headers.get === "function") return headers.get(name)
    const lower = name.toLowerCase()
    for (const key of Object.keys(headers)) {
      if (key.toLowerCase() === lower) return headers[key]
    }
    return null
  }
  const prefetchPurpose =
    getHeader("X-Sec-Purpose") ||
    getHeader("Sec-Purpose") ||
    getHeader("X-Purpose") ||
    getHeader("Purpose")
  if (prefetchPurpose === "prefetch" || prefetchPurpose === "preview") return
  if (getHeader("Turbo-Frame")) return
  toggleDashboardLoading(true)
})

document.addEventListener("turbo:load", () => {
  toggleDashboardLoading(false)
})

const closeModal = (modalId) => {
  const modal = document.getElementById(modalId)
  if (!modal) return
  modal.classList.add("hidden")
}

const openModal = (modalId) => {
  const modal = document.getElementById(modalId)
  if (!modal) return
  modal.classList.remove("hidden")
}

document.addEventListener("click", (event) => {
  const openTrigger = event.target.closest("[data-open-modal]")
  if (openTrigger) {
    openModal(openTrigger.dataset.openModal)
    return
  }
  const closeTrigger = event.target.closest("[data-close-modal]")
  if (closeTrigger) {
    closeModal(closeTrigger.dataset.closeModal)
  }
})

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return
  document.querySelectorAll("[id$='-modal']").forEach((modal) => {
    if (!modal.classList.contains("hidden")) {
      modal.classList.add("hidden")
    }
  })
})
