import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["highlight"]
  
  highlight(event) {
    const targetElement = event.target.closest('[data-related-element-target]')
    if (!targetElement) return
    
    const targetValue = targetElement.dataset.relatedElementTarget
    const relatedElements = this.element.querySelectorAll(`[data-related-element-target="${targetValue}"]`)
    
    relatedElements.forEach(element => {
      element.classList.add(this.highlightClass)
    })
  }

  unhighlight(event) {
    const targetElement = event.target.closest('[data-related-element-target]')
    if (!targetElement) return
    
    const targetValue = targetElement.dataset.relatedElementTarget
    const relatedElements = this.element.querySelectorAll(`[data-related-element-target="${targetValue}"]`)
    
    relatedElements.forEach(element => {
      element.classList.remove(this.highlightClass)
    })
  }
}
