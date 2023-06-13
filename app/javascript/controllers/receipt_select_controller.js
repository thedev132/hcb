import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "receipt", "select", "confirm" ]
  static values = { selected: String }

  select(e) {
    const prevReceiptId = this.selectElement.value + "";

    document.querySelectorAll(".receipt-selected").forEach(el => el.classList.remove("receipt-selected"));

    const receiptId = e.currentTarget.getAttribute("data-receipt-id");

    if (receiptId === prevReceiptId) {
      this.confirmTarget.disabled = true;
      return this.selectElement.value = "";
    }

    this.confirmTarget.disabled = false;
    this.selectElement.value = receiptId;
    e.currentTarget.classList.add("receipt-selected");
  }

  get selectElement() {
    return this.selectTarget.children[0];
  }
}