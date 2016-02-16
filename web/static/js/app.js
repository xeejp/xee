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
        this.chan.join().receive("ok", _ => {
            this.chan.push("fetch", {})
        })
        this.chan.on("update", payload => {
            update(payload.body)
        })
    }

    send_data(data) {
        this.chan.push("client", {body: data})
    }
}
