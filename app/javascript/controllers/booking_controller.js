// app/javascript/controllers/booking_controller.js
// Handles date validation for the loan booking form.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "submitBtn"]

  connect() {
    // Set minimum start date to today
    const today = new Date().toISOString().split("T")[0]
    if (this.hasStartDateTarget) {
      this.startDateTarget.min = today
    }
    this.validateDates()
  }

  validateDates() {
    const startDate = this.hasStartDateTarget ? this.startDateTarget.value : null
    const endDate = this.hasEndDateTarget ? this.endDateTarget.value : null

    if (startDate && this.hasEndDateTarget) {
      // End date must be after start date
      const nextDay = new Date(startDate)
      nextDay.setDate(nextDay.getDate() + 1)
      this.endDateTarget.min = nextDay.toISOString().split("T")[0]

      // Auto-clear end date if it's before start
      if (endDate && endDate <= startDate) {
        this.endDateTarget.value = ""
      }
    }

    // Enable/disable submit
    if (this.hasSubmitBtnTarget) {
      const isValid = startDate && endDate && endDate > startDate
      this.submitBtnTarget.disabled = !isValid
      this.submitBtnTarget.classList.toggle("opacity-50", !isValid)
      this.submitBtnTarget.classList.toggle("cursor-not-allowed", !isValid)
    }
  }
}
