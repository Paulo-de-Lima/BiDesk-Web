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

const openFormModal = () => {
  const modal = document.querySelector("[data-form-modal]")
  if (!modal) return
  requestAnimationFrame(() => {
    modal.classList.add("form-modal--open")
  })
}

const closeFormModal = () => {
  const frame = document.getElementById("resource_modal")
  if (frame) frame.innerHTML = ""
  document.querySelector("[data-form-modal]")?.classList.remove("form-modal--open")
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
    return
  }
  if (event.target.closest("[data-close-form-modal]")) {
    event.preventDefault()
    closeFormModal()
  }
})

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "resource_modal" && event.target.querySelector("[data-form-modal]")) {
    openFormModal()
  }
})

document.addEventListener("turbo:before-fetch-response", (event) => {
  const frame = document.getElementById("resource_modal")
  if (!frame?.querySelector("[data-form-modal]")) return
  const fetchResponse = event.detail?.fetchResponse
  if (fetchResponse?.redirected) closeFormModal()
})

document.addEventListener("click", (event) => {
  const toggle = event.target.closest("[data-cliente-expand]")
  if (!toggle) return
  event.preventDefault()
  event.stopPropagation()

  const clienteId = toggle.dataset.clienteExpand
  const panel = document.getElementById(`${clienteId}-mesas`)
  if (!panel) return

  const isOpen = toggle.getAttribute("aria-expanded") === "true"
  toggle.setAttribute("aria-expanded", isOpen ? "false" : "true")
  panel.classList.toggle("hidden", isOpen)
  panel.classList.toggle("cliente-mesas--open", !isOpen)
  toggle.querySelector("[data-chevron]")?.classList.toggle("rotate-90", !isOpen)
})

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return
  if (document.querySelector("[data-form-modal].form-modal--open")) {
    closeFormModal()
    return
  }
  document.querySelectorAll("[id$='-modal']").forEach((modal) => {
    if (!modal.classList.contains("hidden")) {
      modal.classList.add("hidden")
    }
  })
  document.querySelectorAll("[data-mobile-nav]").forEach((nav) => {
    nav.classList.add("hidden")
    nav.dataset.open = "false"
  })
})

// Mobile navigation
document.addEventListener("click", (event) => {
  const toggle = event.target.closest("[data-mobile-nav-toggle]")
  if (toggle) {
    const nav = document.querySelector("[data-mobile-nav]")
    if (!nav) return
    const isOpen = nav.dataset.open === "true"
    nav.classList.toggle("hidden", isOpen)
    nav.dataset.open = isOpen ? "false" : "true"
    toggle.setAttribute("aria-expanded", isOpen ? "false" : "true")
    return
  }
  if (event.target.closest("[data-mobile-nav] a")) {
    const nav = document.querySelector("[data-mobile-nav]")
    if (nav) {
      nav.classList.add("hidden")
      nav.dataset.open = "false"
      document.querySelector("[data-mobile-nav-toggle]")?.setAttribute("aria-expanded", "false")
    }
  }
})

// Delete confirmation modal
let pendingDeleteForm = null

document.addEventListener("click", (event) => {
  const trigger = event.target.closest("[data-confirm-delete]")
  if (!trigger) return
  event.preventDefault()
  event.stopPropagation()

  const form = trigger.closest("form")
  if (!form) return

  pendingDeleteForm = form
  const modal = document.getElementById("confirm-delete-modal")
  const message = document.getElementById("confirm-delete-message")
  const title = document.getElementById("confirm-delete-title")
  if (!modal || !message) return

  if (title) title.textContent = trigger.dataset.confirmTitle || "Confirmar exclusão"
  message.textContent =
    trigger.dataset.confirmMessage ||
    "Esta ação não pode ser desfeita. Tem certeza que deseja continuar?"

  openModal("confirm-delete-modal")
  document.getElementById("confirm-delete-submit")?.focus()
})

document.addEventListener("click", (event) => {
  if (event.target.id !== "confirm-delete-submit") return
  if (pendingDeleteForm) {
    pendingDeleteForm.requestSubmit()
    pendingDeleteForm = null
  }
  closeModal("confirm-delete-modal")
})

// Clickable table rows
document.addEventListener("click", (event) => {
  if (event.target.closest("[data-no-row-nav]")) return
  if (event.target.closest("a, button, input, select, textarea, label, [data-confirm-delete]")) return

  const row = event.target.closest("[data-row-href]")
  if (!row) return
  const href = row.dataset.rowHref
  if (href) Turbo.visit(href)
})

document.addEventListener("keydown", (event) => {
  if (event.key !== "Enter" && event.key !== " ") return
  const row = event.target.closest("[data-row-href]")
  if (!row || !row.contains(document.activeElement)) return
  if (event.key === " ") event.preventDefault()
  const href = row.dataset.rowHref
  if (href) Turbo.visit(href)
})

// Dismiss flash messages
document.addEventListener("click", (event) => {
  const btn = event.target.closest("[data-dismiss-flash]")
  if (!btn) return
  const flash = btn.closest("[data-flash]")
  flash?.remove()
  const container = document.querySelector("[data-flash-container]")
  if (container && !container.querySelector("[data-flash]")) container.remove()
})

// Form submit loading state
document.addEventListener("submit", (event) => {
  const form = event.target
  if (!(form instanceof HTMLFormElement)) return
  if (form.dataset.confirmDeleteForm) return

  const submit = form.querySelector("[type='submit']")
  if (!submit || submit.dataset.loading === "true") return

  submit.dataset.loading = "true"
  submit.dataset.originalText = submit.tagName === "BUTTON" ? submit.textContent : submit.value
  submit.disabled = true
  if (submit.tagName === "BUTTON") {
    submit.textContent = "Salvando…"
  } else {
    submit.value = "Salvando…"
  }
})

// Filter forms: show loading on toolbar
document.addEventListener("submit", (event) => {
  const form = event.target
  if (!(form instanceof HTMLFormElement) || !form.dataset.filterForm) return
  const toolbar = form.closest("[data-filter-toolbar]")
  if (toolbar) {
    toolbar.setAttribute("aria-busy", "true")
    toolbar.classList.add("opacity-70", "pointer-events-none")
  }
})

document.addEventListener("turbo:load", () => {
  document.querySelectorAll("[data-filter-toolbar][aria-busy='true']").forEach((el) => {
    el.removeAttribute("aria-busy")
    el.classList.remove("opacity-70", "pointer-events-none")
  })

  document.querySelectorAll("[type='submit'][data-loading='true']").forEach((submit) => {
    submit.disabled = false
    submit.dataset.loading = "false"
    const original = submit.dataset.originalText
    if (!original) return
    if (submit.tagName === "BUTTON") submit.textContent = original
    else submit.value = original
  })

  const errorField = document.querySelector("[data-field-error='true']")
  if (errorField) {
    errorField.focus()
    errorField.scrollIntoView({ behavior: "smooth", block: "center" })
  }

  const formErrors = document.getElementById("form-errors")
  if (formErrors) formErrors.focus()
})
