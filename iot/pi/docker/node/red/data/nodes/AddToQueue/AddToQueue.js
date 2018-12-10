module.exports = function (RED) {
    "use strict";

    function addToQueue(config) {
        RED.nodes.createNode(this, config);

        var node = this;

        this.on('input', function (msg) {

            var obj = {
                "id":"11111",
                "name": config.name,
                "callback": config.callback
            };

            msg.payload=obj;
            
            node.send(msg);
        });

    }

    RED.nodes.registerType("toQueue", addToQueue);
}
