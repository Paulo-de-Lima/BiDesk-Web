import "@hotwired/turbo-rails"
import { bindInputMasksIn, initInputMasks } from "input_masks"

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
  initInputMasks()
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
  const passwordToggle = event.target.closest("[data-action='toggle-password']")
  if (passwordToggle) {
    const field = passwordToggle.closest(".login-field")
    const input = field?.querySelector(".login-input--password")
    if (!input) return
    const showIcon = passwordToggle.querySelector(".login-icon-show")
    const hideIcon = passwordToggle.querySelector(".login-icon-hide")
    const isHidden = input.type === "password"
    input.type = isHidden ? "text" : "password"
    showIcon?.classList.toggle("hidden", isHidden)
    hideIcon?.classList.toggle("hidden", !isHidden)
    passwordToggle.setAttribute("aria-label", isHidden ? "Ocultar senha" : "Mostrar senha")
    return
  }

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
  bindInputMasksIn(event.target)

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

function toggleExpandableRow(toggle, panelIdSuffix, openClass) {
  const rowId = toggle.dataset.clienteExpand || toggle.dataset.manutencaoExpand
  const panel = document.getElementById(`${rowId}${panelIdSuffix}`)
  if (!panel) return

  const isOpen = toggle.getAttribute("aria-expanded") === "true"
  toggle.setAttribute("aria-expanded", isOpen ? "false" : "true")
  panel.classList.toggle("hidden", isOpen)
  panel.classList.toggle(openClass, !isOpen)
  toggle.querySelector("[data-chevron]")?.classList.toggle("rotate-90", !isOpen)
}

document.addEventListener("click", (event) => {
  const toggle = event.target.closest("[data-cliente-expand]")
  if (!toggle) return
  event.preventDefault()
  event.stopPropagation()
  toggleExpandableRow(toggle, "-mesas", "cliente-mesas--open")
})

document.addEventListener("click", (event) => {
  const toggle = event.target.closest("[data-manutencao-expand]")
  if (!toggle) return
  event.preventDefault()
  event.stopPropagation()
  toggleExpandableRow(toggle, "-itens", "manutencao-itens--open")
})

document.addEventListener("click", (event) => {
  const addBtn = event.target.closest("[data-manutencao-item-add]")
  if (!addBtn) return
  event.preventDefault()

  const container = addBtn.closest("[data-manutencao-itens]")
  const template = container?.querySelector("[data-manutencao-item-template]")
  const list = container?.querySelector("[data-manutencao-itens-list]")
  if (!template || !list) return

  const index = Date.now()
  list.insertAdjacentHTML("beforeend", template.innerHTML.replace(/NEW_RECORD/g, String(index)))
})

document.addEventListener("click", (event) => {
  const removeBtn = event.target.closest("[data-manutencao-item-remove]")
  if (!removeBtn) return
  event.preventDefault()

  const row = removeBtn.closest("[data-manutencao-item-row]")
  if (!row) return

  const destroyField = row.querySelector("[data-manutencao-item-destroy]")
  const idField = row.querySelector("input[name*='[id]']")
  if (idField?.value) {
    if (destroyField) destroyField.value = "1"
    row.classList.add("hidden")
  } else {
    row.remove()
  }
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
  if (form.dataset.confirmDeleteForm || form.dataset.noSubmitLoading) return

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

  initInputMasks()
})
