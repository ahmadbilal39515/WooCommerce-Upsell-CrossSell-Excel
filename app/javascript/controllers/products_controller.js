import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static targets = ["main_modal", "spinner", "startIndex", "endIndex", "rangeWarning"]

  connect() {
    this.modal = new Modal(this.main_modalTarget)
  }

  openModal(){
    this.modal.toggle()
  }

  closeModal(){
    this.modal.toggle()
  }

  submit(event){
    event.preventDefault();
    let startIndex = this.startIndexTarget.value
    let endIndex = this.endIndexTarget.value
    if(endIndex - startIndex <=1000){
      this.spinnerTarget.classList.remove("hidden");

      fetch(`/get_csv?startIndex=${startIndex}&endIndex=${endIndex}`,{
        headers:{
           'Content-Type': 'application/json',
          'Accept': 'application/json'
        }
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok ' + response.statusText);
        }
        return response.json(); // Convert the response to JSON
      })
      .then(data => {
        const blob = new Blob([data.csv_data], { type: 'text/csv' });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = data.filename; // Use the filename from the response
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        this.spinnerTarget.classList.add("hidden");
      })
      .catch(error => {
        console.error('There was a problem with the fetch operation:', error);

        // Hide the spinner if there was an error
        this.spinnerTarget.classList.add("hidden");
        this.modal.toggle()
      });

      // Hide the warning message if it was previously shown
      this.rangeWarningTarget.classList.add("hidden");

    }else{
      this.rangeWarningTarget.classList.remove("hidden")
    }
  }
}
