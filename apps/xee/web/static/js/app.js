import {Socket} from "phoenix"

window.Experiment = class Experiment {
  constructor(topic, token, update) {
    this.topic = topic
    this.x_token = topic.substring('x:'.length)
    this.socket = new Socket("/socket")
    this.socket.connect()
    this.chan = this.socket.channel(topic, {token: token})
    if (update != undefined) {
      this.onUpdate(update)
    }

    // Redirect
    this.chan.on("redirect", payload => {
      const xid = payload.body
      window.location = "/experiment/" + xid
    })
  }

  send_data(data) {
    this.chan.push("client", {body: data})
  }


  onUpdate(func) {
    this.chan.join().receive("ok", _ => {
      this.chan.push("fetch", {})
      // Ping
      setInterval(() => this.chan.push("ping"), 10000)
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

  openParticipantPage(id) {
    window.open('/experiment/' + this.x_token + '/host/' + id, '_blank')
  }
}
