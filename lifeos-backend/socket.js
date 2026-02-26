function initSocket(server) {
  const io = require("socket.io")(server, { cors: { origin: "*" } });

  io.on("connection", (socket) => {
    console.log("Client connected:", socket.id);

    socket.on("taskUpdate", (data) => {
      io.emit("taskUpdated", data);
    });

    socket.on("sessionUpdate", (data) => {
      io.emit("sessionUpdated", data);
    });

    socket.on("disconnect", () => {
      console.log("Client disconnected:", socket.id);
    });
  });

  return io;
}

module.exports = initSocket;