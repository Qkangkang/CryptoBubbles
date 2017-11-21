# Real time web game that uses ethereum blockchain

## Development
 - Server
 The server is written in Go and is using socket.io for communication with the frontend
 You can run the server by going to /server and running `go run server.go`
 Server listens on port 6000

 - Frontend
 The game is written in Phaser and opensource game engine.
 The menu and other settings are written in Preact a lightweight version on React.

 To run the frontend navigate to /frontend
 Run `npm install` or `yarn install`
 And run `npm run dev` a development server will start