// app/javascript/controllers/flash_controller.js
// Auto-dismisses flash messages after a delay.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.messageTargets.forEach((msg) => {
      setTimeout(() => this.fadeOut(msg), 5000)
    })
  }

  dismiss(event) {
    const msg = event.currentTarget.closest("[data-flash-target='message']")
    if (msg) this.fadeOut(msg)
  }

  fadeOut(element) {
    element.style.transition = "opacity 0.3s, transform 0.3s"
    element.style.opacity = "0"
    element.style.transform = "translateY(-10px)"
    setTimeout(() => element.remove(), 300)
  }
}
