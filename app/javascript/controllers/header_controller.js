import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "toggleButton", "lightIcon", "darkIcon"];

  static values = {};

  connect() {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      this.lightIconTarget.classList.remove("hidden");
    } else {
      this.darkIconTarget.classList.remove("hidden");
    }
  }

  toggleThemeMode = (event) => {
    this.darkIconTarget.classList.toggle("hidden");
    this.lightIconTarget.classList.toggle("hidden");

    if (localStorage.getItem("theme")) {
      if (localStorage.getItem("theme") === "light") {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
      } else {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
      }
    } else {
      if (document.documentElement.classList.contains("dark")) {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
      } else {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
      }
    }
  };

  disconnect() {}
}
