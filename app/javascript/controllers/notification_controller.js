// app/javascript/controllers/notification_controller.js
// Manages the notification dropdown and real-time badge updates via ActionCable.
import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this.isOpen = false
    this.setupCable()
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  toggle(event) {
    event.stopPropagation()
    this.isOpen = !this.isOpen

    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden", !this.isOpen)
    }

    // Load notifications on first open
    if (this.isOpen) {
      this.loadNotifications()
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target) && this.isOpen) {
      this.isOpen = false
      if (this.hasDropdownTarget) {
        this.dropdownTarget.classList.add("hidden")
      }
    }
  }

  loadNotifications() {
    const list = document.getElementById("notifications_list")
    if (!list) return

    fetch("/notifications", {
      headers: {
        "Accept": "text/html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.text())
    .then(html => {
      // Extract notification items from full page if needed
      const container = document.createElement("div")
      container.innerHTML = html
      const items = container.querySelectorAll("[id^='notification_']")
      list.innerHTML = ""
      if (items.length > 0) {
        items.forEach(item => {
          const clone = item.cloneNode(true)
          clone.classList.add("px-4", "py-3")
          list.appendChild(clone)
        })
      } else {
        list.innerHTML = '<p class="p-6 text-sm text-slate-400 text-center">🔔 No notifications yet</p>'
      }
    })
    .catch(() => {
      list.innerHTML = '<p class="p-4 text-sm text-gray-500">Could not load notifications.</p>'
    })
  }

  setupCable() {
    const consumer = createConsumer()
    this.subscription = consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => {
        try {
          const notification = JSON.parse(data)
          this.handleNewNotification(notification)
        } catch (e) {
          console.warn("Failed to parse notification:", e)
        }
      }
    })
  }

  handleNewNotification(notification) {
    // Update badge count
    this.updateBadge(notification.unread_count)

    // Prepend to dropdown if open
    const list = document.getElementById("notifications_list")
    if (list) {
      const item = document.createElement("div")
      item.className = "px-4 py-3 bg-emerald-50 dark:bg-emerald-900/20"
      item.innerHTML = `
        <div class="flex items-start gap-3">
          <div class="w-8 h-8 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
            <span class="text-white text-xs font-bold">${notification.actor_initial}</span>
          </div>
          <div>
            <p class="text-sm text-gray-800 dark:text-gray-200">${notification.message}</p>
            <p class="text-xs text-gray-400 mt-1">Just now</p>
          </div>
        </div>
      `
      list.prepend(item)
    }

    // Show a brief toast
    this.showToast(notification.message)
  }

  updateBadge(count) {
    let badge = document.getElementById("notifications_badge")
    if (count > 0) {
      if (!badge) {
        const button = this.element.querySelector("button")
        badge = document.createElement("span")
        badge.id = "notifications_badge"
        badge.className = "absolute -top-0.5 -right-0.5 inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-red-500 rounded-full animate-pulse"
        button.appendChild(badge)
      }
      badge.textContent = count
    } else if (badge) {
      badge.remove()
    }
  }

  showToast(message) {
    const toast = document.createElement("div")
    toast.className = "fixed bottom-6 right-6 px-5 py-3 bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 rounded-xl shadow-2xl text-sm font-medium z-[100] animate-slide-up"
    toast.textContent = `🔔 ${message}`
    document.body.appendChild(toast)

    setTimeout(() => {
      toast.style.opacity = "0"
      toast.style.transition = "opacity 0.3s"
      setTimeout(() => toast.remove(), 300)
    }, 4000)
  }
}
