import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "file", "name" ]

  connect() {
  }

  fileChanged() {
    const element = this.fileTarget
    this.nameTarget.value = element.files[0].name
  }
}
