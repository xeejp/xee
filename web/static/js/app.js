import {Socket} from "phoenix"
window.Experiment = class Experiment {
  constructor(topic, token, update) {
    this.socket = new Socket("/socket")
    this.socket.connect()
    this.chan = this.socket.channel(topic, {token: token})
    if (update != undefined) {
      this.onUpdate(update)
    }
    setInterval(() => this.chan.push("ping"), 10000)
  }

  send_data(data) {
    this.chan.push("client", {body: data})
  }

  onUpdate(func) {
    this.chan.join().receive("ok", _ => {
      this.chan.push("fetch", {})
    })
    this.chan.on("update", payload => {
      func(payload.body)
    })
  }

  onReceiveMessage(func) {
    this.chan.join()
    this.chan.on("message", payload => {
      func(payload.body)
    })
  }
}
