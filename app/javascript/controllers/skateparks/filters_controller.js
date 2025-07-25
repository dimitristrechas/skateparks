import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countrySelect", "stateSelect"];

  static values = {};

  connect() {
    if (this.hasCountrySelectTarget) {
      this.countrySelectTarget.addEventListener("change", this.handleCountryChange);
    }
  }

  handleCountryChange = (event) => {
    if (this.hasStateSelectTarget) {
      this.stateSelectTarget.value = "";
    }
    if (event.target.value) {
      this.fetchAvailableStates(event.target.value);
    } else {
      this.stateSelectTarget.value = "";
      this.stateSelectTarget.disabled = true;
    }
  };

  fetchAvailableStates(countryCode) {
    fetch(`/available_states/${countryCode}`)
      .then((response) => response.json())
      .then((states) => {
        this.stateSelectTarget.innerHTML = this.buildStateOptions(states);
        this.stateSelectTarget.disabled = false;
      });
  }

  buildStateOptions(states) {
    const defaultOption = `<option selected value="">All States</option>`;

    return (
      defaultOption +
      states
        .map(({ code, name }) => {
          return `<option  value="${code}">${name}</option>`;
        })
        .join("")
    );
  }
}
