import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["countrySelect"];

  connect() {
    if (this.hasCountrySelectTarget) {
      this.countrySelectTarget.addEventListener("change", this.handleCountryChange);
    }
  }

  handleCountryChange = (event) => {
    const countryCode = event.target.value;

    this.fetchAvailableStates(countryCode);
  };

  fetchAvailableStates(countryCode) {
    fetch(`/available_states/${countryCode}`, {
      method: "GET",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }
}
