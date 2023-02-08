import { Controller } from '@hotwired/stimulus'
import JSConfetti from 'js-confetti'

const jsConfetti = new JSConfetti()

export default class extends Controller {
  party() {
    jsConfetti.addConfetti()
  }
}
