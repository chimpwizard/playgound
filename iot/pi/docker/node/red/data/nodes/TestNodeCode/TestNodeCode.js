module.exports = function (RED) {
    "use strict";

    function TestNodeCode(config) {
        RED.nodes.createNode(this, config);

        var node = this;

        this.on('input', function (msg) {
            msg.payload.testNodeResult = "Results go here.";
            node.send(msg);
        });

        this.on('close', function () {
            this.status({ fill: "red", shape: "ring", text: "disconnected" });
        });
    }

    RED.nodes.registerType("test", TestNodeCode);
}
