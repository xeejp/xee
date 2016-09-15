// host
function onUpdate(data) {
    console.log(data)
}
var _ex = require("web/static/js/app")
var _experiment = new _ex.Experiment(_topic, _token, onUpdate)
function send_data(data) {
  _experiment.send_data(data)
}
