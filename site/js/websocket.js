/*
 * This function binds the ports defined in WebSocket.elm to
 * the browser's webSocket API.
 */
function bind(app) {
    // Exit predictably if the ports aren't in use in Elm
    if (!app.ports || !(app.ports.toSocket && app.ports.fromSocket)) {
        console.log(
            "Could not find 'toSocket' and 'fromSocket' ports on app. They may not be in use yet."
        );
        return;
    }

    // Handle events from Elm
    app.ports.toSocket.subscribe((message) => {
            if (socket) {
                socket.send(JSON.stringify(message));
            } else {
                console.log(
                    `No open socket. Cannot send ${message}`
                );
            }
    });

    let toElm = app.ports.fromSocket;
    let url = "ws://localhost:8887";
    let socket = new WebSocket( url , []);

    socket.onopen = openHandler.bind(null, toElm, socket, url);
    socket.onmessage = messageHandler.bind(null, toElm, socket, url);
    socket.onerror = errorHandler.bind(null, toElm, socket, url);
    socket.onclose = closeHandler.bind(null, toElm, socket, url);

}

// SOCKET HELPER FUNCTIONS

// When the socket opens, we send a message to Elm with some metadata
// about the negotiated connection.
function openHandler(toElm, socket, url, event) {
    toElm.send({
        msgType: "Connected",
        msg: {
            url: url,
            binaryType: socket.binaryType,
            extensions: socket.extensions,
            protocol: socket.protocol
        }
    });
}

// When we get a message from the socket, we send it to Elm.
function messageHandler(toElm, socket, url, event) {
    if (typeof event.data == "string") {
        //console.log(event.data);
        let obj = JSON.parse(event.data);
        console.log(obj);
        toElm.send(obj);
    } else {
        console.log(`No binary message handling implemented`);
    }
}

// Send errors to Elm
function errorHandler(toElm, socket, url, event) {
    toElm.send({
        msgType: "Error",
        msg: {
            url: url,
            binaryType: socket.binaryType,
            extensions: socket.extensions,
            protocol: socket.protocol,
            event: event
        }
    });
}

// Send close notifications to Elm, and stop tracking the socket. Include the
// number of bytes still unset.
function closeHandler(toElm, socket, url, event) {
    toElm.send({
        msgType: "Closed",
        msg: {
            url: url,
            binaryType: socket.binaryType,
            extensions: socket.extensions,
            protocol: socket.protocol,
            unsentBytes: socket.bufferedAmount
        }
    });
}