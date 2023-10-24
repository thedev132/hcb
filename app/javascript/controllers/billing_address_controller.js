import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['country', 'state']

  setCountry() {
    if(this.countryTarget.value == "US"){
      this.stateTarget.disabled == "false"
    }
    else {
      this.stateTarget.value == ""
      this.stateTarget.disabled == "true"
    }
  }
}
