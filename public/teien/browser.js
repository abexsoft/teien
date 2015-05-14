teien.Browser = function(ws_uri, app_klass) {
    //this.ws = new WebSocket(ws_uri);
    this.world = new teien.World(app_klass);

    this.world.setup(ws_uri);
    
//    this.ws.onmessage = this.receiveMessage.bind(this);
};
/*
teien.Browser.prototype.receiveMessage = function(ws_msg){
    var event = JSON.parse(ws_msg.data);
    switch(event.type){
    case "connected":
        this.world.connected(event);
        break;
    case "disconnected":
        this.world.disconnected(event);
        break;
    default:
        this.world.receiveMessage(event);
    }
};
*/
