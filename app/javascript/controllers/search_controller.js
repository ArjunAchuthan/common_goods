// app/javascript/controllers/search_controller.js
// Handles debounced search and filter submissions via Turbo Frames.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.timeout = null
  }

  debounceSearch() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submit()
    }, 350)
  }

  submit() {
    const form = this.element.closest("form") || this.element.querySelector("form")
    if (form) {
      form.requestSubmit()
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
