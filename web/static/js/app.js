import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", resp => {
//   console.log("Joined succesffuly!", resp)
// })

import {Socket} from "phoenix"

// let socket = new Socket("/ws")
// socket.connect()
// let chan = socket.chan("topic:subtopic", {})
// chan.join().receive("ok", resp => {
//   console.log("Joined succesffuly!", resp)
// })

export class Experiment {
    constructor(topic, type, update) {
        this.socket = new Socket("/experiment")
        this.socket.connect({token: token})
        this.chan = this.socket.chan(topic, {})
        this.chan.join().receive("ok", resp => {})
        this.chan.on("update", payload => {
            update(payload.body)
        })
    }

    send_data(data) {
        this.chan.push("client", {body: data})
    }
}
