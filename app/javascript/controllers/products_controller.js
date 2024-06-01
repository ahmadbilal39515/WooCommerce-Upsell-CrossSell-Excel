import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static targets = ["main_modal", "spinner"]

  connect() {
    this.modal = new Modal(this.main_modalTarget)
  }

  openModal(){
    this.modal.toggle()
  }

  closeModal(){
    this.modal.toggle()
  }

  submitButton(event){
    event.preventDefault()
    alert("ssddd")
  }
}
