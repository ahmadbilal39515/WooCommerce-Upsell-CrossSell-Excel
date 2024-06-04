import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static targets = ["main_modal", "spinner", "startDate", "endDate"]

  connect() {
    this.modal = new Modal(this.main_modalTarget)
  }

  openModal(){
    this.modal.toggle()
  }

  closeModal(){
    this.modal.toggle()
  }

  form(){
    var startDate = this.startDateTarget.value
    var endDate = this.endDateTarget.value

    if (!startDate || !endDate) {
      alert("Both start date and end date are required.");
      return;
    }

    const url = `/get_csv?startDate=${encodeURIComponent(startDate)}&endDate=${encodeURIComponent(endDate)}`;
    this.closeModal()
    fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      let jobId = data.job_id;
      this.checkJobStatus(jobId);
    })
    .catch(error => console.error('Error:', error));
  }

  checkJobStatus(jobId) {

    const intervalId = setInterval(() => {
      fetch(`/csv_status/${jobId}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.ready) {
          clearInterval(intervalId);
          document.getElementById('downloadLink').style.display = 'block';
          document.getElementById('csvLink').setAttribute('href', data.download_link);
        }
      })
      .catch(error => console.error('Error:', error));
    }, 2000);
  }
}
