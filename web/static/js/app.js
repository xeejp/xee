import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", resp => {
//   console.log("Joined succesffuly!", resp)
// })

export class Experiment {
    constructor(topic, token, update) {
        this.socket = new Socket("/socket")
        this.socket.connect()
        this.chan = this.socket.chan(topic, {token: token})
        if (update != undefined) {
            this.onUpdate(update)
        }
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
}
