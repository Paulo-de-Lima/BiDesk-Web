// Entrypoint for the importmap (app/views/layouts/application.html.erb)
// Rails uses this file to load client‑side libraries such as Turbo and
// Stimulus.  Without it the `javascript_importmap_tags` helper is a no‑op
// (see development.log: "Importmap skipped missing path: application.js").

import "@hotwired/turbo-rails"
// import "@hotwired/stimulus"
// import "@hotwired/stimulus-loading"
// add additional JavaScript modules below

// you can require other files as needed, for example:
// import "controllers"  // if you have `app/javascript/controllers`

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

document.addEventListener("turbo:before-fetch-request", () => {
  toggleDashboardLoading(true)
})

document.addEventListener("turbo:load", () => {
  toggleDashboardLoading(false)
})
