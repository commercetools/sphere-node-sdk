import { EventEmitter } from 'events'

function ensureAll () {
  while (this.holdingQueue.length > 0) {
    if (this.paused) break

    const { event, payload } = this.holdingQueue.shift()
    this.emit(event, payload)
  }
}

export default class Dispatcher extends EventEmitter {
  constructor () {
    super()

    this.paused = false
    this.holdingQueue = []
  }

  pause () {
    this.paused = true
  }

  resume () {
    this.paused = false
    ensureAll.call(this)
  }

  dispatch (event, payload) {
    this.holdingQueue.push({ event, payload })
    ensureAll.call(this)
  }

}
