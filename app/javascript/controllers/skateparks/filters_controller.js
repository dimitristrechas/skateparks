import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countrySelect", "stateSelect"];

  connect() {
    if (this.hasCountrySelectTarget) {
      this.countrySelectTarget.addEventListener("change", this.handleCountryChange);
    }
  }

  handleCountryChange = (event) => {
    const countryCode = event.target.value;
    
    if (this.hasStateSelectTarget) {
      this.stateSelectTarget.value = "";
    }
    
    if (countryCode) {
      this.fetchAvailableStates(countryCode);
    } else {
      this.stateSelectTarget.value = "";
      this.stateSelectTarget.disabled = true;
    }
  };

  fetchAvailableStates(countryCode) {
    fetch(`/available_states/${countryCode}`, {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html));
  }
}