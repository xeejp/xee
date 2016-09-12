// participant
function receiveMessage(data) {
    console.log(data)
}
var _experiment = new Experiment(_topic, _token);
_experiment.onReceiveMessage(receiveMessage);
function send_data(data) {
    console.log(data);
    _experiment.send_data(data);
}
