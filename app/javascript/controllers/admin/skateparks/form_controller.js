import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  onImageClick(event) {
    if (window.confirm("Do you really want to delete this image?")) {
      event.currentTarget.remove();
    }
  }
}
