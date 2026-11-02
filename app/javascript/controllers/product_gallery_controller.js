
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "thumbnail", "counter"]

  connect() {
    this.currentIndex = 0
    this.showImage(0)
  }

  next() {
    if (this.imageTargets.length <= 1) return

    const nextIndex = (this.currentIndex + 1) % this.imageTargets.length
    this.showImage(nextIndex)
  }

  previous() {
    if (this.imageTargets.length <= 1) return

    const previousIndex =
      (this.currentIndex - 1 + this.imageTargets.length) %
      this.imageTargets.length

    this.showImage(previousIndex)
  }

  select(event) {
    const index = Number(event.currentTarget.dataset.index)
    this.showImage(index)
  }

  showImage(index) {
    if (this.imageTargets.length === 0) return

    this.currentIndex = index

    this.imageTargets.forEach((image, i) => {
      image.classList.toggle("d-none", i !== index)
    })

    this.thumbnailTargets.forEach((thumbnail, i) => {
      thumbnail.classList.toggle("active", i === index)
      thumbnail.setAttribute("aria-pressed", i === index ? "true" : "false")
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent =
        `${index + 1} / ${this.imageTargets.length}`
    }
  }
}
