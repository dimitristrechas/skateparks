import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["stateSelect", "countrySelect"];

  connect() {
    if (this.countrySelectTarget.value) {
      this.fetchStates(this.countrySelectTarget.value);
    }
  }

  onCountryChange(event) {
    if (event.target.value) {
      this.fetchStates(event.target.value);
    } else {
      this.stateSelectTarget.innerHTML = "";
      this.stateSelectTarget.disabled = true;
    }
  }

  fetchStates(countryCode) {
    fetch(`/admin/states/${countryCode}`)
      .then((response) => response.json())
      .then((states) => {
        this.stateSelectTarget.innerHTML = this.buildStateOptions(states);
        this.stateSelectTarget.disabled = false;
      });
  }

  buildStateOptions(states) {
    return Object.entries(states)
      .map(([code, state]) => `<option value="${code}">${state.name}</option>`)
      .join("");
  }

  onImageClick(event) {
    if (window.confirm("Do you really want to delete this image?")) {
      event.currentTarget.remove();
    }
  }
}
