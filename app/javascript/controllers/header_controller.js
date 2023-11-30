import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["image", "toggleButton", "lightIcon", "darkIcon"];

  static values = {
    logoDarkUrl: String,
    logoLightUrl: String,
  };

  imageTargetConnected() {
    if (
      localStorage.theme === "dark" ||
      (!("theme" in localStorage) &&
        window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      this.lightIconTarget.classList.remove("hidden");
      this.imageTarget.src = this.logoDarkUrlValue;
    } else {
      this.darkIconTarget.classList.remove("hidden");
      this.imageTarget.src = this.logoLightUrlValue;
    }
  }

  toggleThemeMode = (event) => {
    this.darkIconTarget.classList.toggle("hidden");
    this.lightIconTarget.classList.toggle("hidden");

    if (localStorage.getItem("theme")) {
      if (localStorage.getItem("theme") === "light") {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
        this.imageTarget.src = this.logoDarkUrlValue;
      } else {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
        this.imageTarget.src = this.logoLightUrlValue;
      }
    } else {
      if (document.documentElement.classList.contains("dark")) {
        document.documentElement.classList.remove("dark");
        localStorage.setItem("theme", "light");
        this.imageTarget.src = this.logoLightUrlValue;
      } else {
        document.documentElement.classList.add("dark");
        localStorage.setItem("theme", "dark");
        this.imageTarget.src = this.logoDarkUrlValue;
      }
    }
  };

  disconnect() {}
}
