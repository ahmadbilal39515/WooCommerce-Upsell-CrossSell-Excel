import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="up-cross-sell"
export default class extends Controller {
  static targets=["modal"]

  // connect() {
  //   this.modal = new Modal(this.modalTarget)
  // }

  // openModal(){

  //   // alert("Sdsfds")
  //   this.modalelement.toggle();
  // }

  openModal() {
    this.modalTarget.classList.add("open");
  }

}