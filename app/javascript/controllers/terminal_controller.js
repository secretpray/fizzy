import { Controller } from "@hotwired/stimulus"
import { HttpStatus } from "helpers/http_helpers"

export default class extends Controller {
  static targets = [ "input", "form", "confirmation" ]
  static classes = [ "error", "confirmation" ]

  // Actions

  focus() {
    this.inputTarget.focus()
  }

  executeCommand(event) {
    if (event.detail.success) {
      this.#reset()
    } else {
      const response = event.detail.fetchResponse.response
      this.#handleErrorResponse(response)
    }
  }

  restoreCommand(event) {
    this.#reset(event.target.dataset.line)
    this.focus()
  }

  async #handleErrorResponse(response) {
    const status = response.status
    const message = await response.text()

    if (status === HttpStatus.UNPROCESSABLE) {
      this.#showError()
    } else if (status === HttpStatus.CONFLICT) {
      this.#requestConfirmation(message)
    }
  }

  #reset(inputValue = "") {
    this.formTarget.reset()
    this.inputTarget.value = inputValue
    this.confirmationTarget.value = ""

    this.element.classList.remove(this.errorClass)
    this.element.classList.remove(this.confirmationClass)
  }

  #showError() {
    this.element.classList.add(this.errorClass)
  }

  async #requestConfirmation(message) {
    const originalInputValue = this.inputTarget.value
    this.element.classList.add(this.confirmationClass)
    this.inputTarget.value = `${message}? [Y/n] `

    try {
      await this.#waitForConfirmation()
      this.#submitWithConfirmation(originalInputValue)
    } catch {
      this.#reset(originalInputValue)
    }
  }

  #waitForConfirmation() {
    return new Promise((resolve, reject) => {
      this.inputTarget.addEventListener("keydown", (event) => {
        event.preventDefault()
        const key = event.key.toLowerCase()

        if (key === "enter" || key === "y") {
          resolve()
        } else {
          reject()
        }
      }, { once: true })
    })
  }

  #submitWithConfirmation(inputValue) {
    this.inputTarget.value = inputValue
    this.confirmationTarget.value = "confirmed"
    this.formTarget.requestSubmit()
  }
}
