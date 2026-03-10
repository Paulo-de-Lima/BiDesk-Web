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
