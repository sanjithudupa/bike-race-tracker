const express = require('express');
const app = express();
const server = app.listen(3000, () => { console.log('listening on *:3000'); });
const io = require('socket.io')(server);

let users = {}
let races = {}

app.get('/rooms', (req, res) => {
  // for (var key in races) {
  //   // check if the property/key is defined in the object itself, not in parent
  //   if (races.hasOwnProperty(key)) {           
  //       console.log(key, races[key]);
  //   }
  // }
  res.send(races)
});

io.on('connection', function(clientSocket){
  clientSocket.emit("youConnected")

  clientSocket.on('sendConnect', (data) => {
    users[clientSocket.id] = data

    console.log(clientSocket.id + " joined as " + data)
  });

  clientSocket.on('joinRace', (data) => {
    clientSocket.join(data)

    let joinState = "join"

    if(races[data] != null && races[data].toString().substring(0,4) == "true"){
      clientSocket.emit("raceAlreadyStarted")
    }else{
      if(data in races && races[data] != [false] && races[data] != [true]){
        joinRace(data, clientSocket.id)
      }else{
        createNewRace(data, clientSocket.id)
        joinState = "create"
      }

      clientSocket.emit("youJoinedRace", joinState, races[data].toString())
      io.in(data).emit("userListUpdate", races[data].toString())

      console.log(races[data])
      // console.log(races[data])

      console.log(clientSocket.id + " joined " + data)
    }

    
  });

  clientSocket.on('startRace', (data) =>{
    races[data][0] = true;
    io.in(data).emit("userListUpdate", races[data].toString())
  });

  clientSocket.on('disconnect', function(){
    delete users[clientSocket.id]
    let emitKey = ""

    for (var key in races){
      console.log('this', key)
      if(races[key].includes(clientSocket.id)){
        console.log("someone left in", key)
        emitKey = key;
        let arrayStr = races[key].toString()
        let host = arrayStr.substring(arrayStr.indexOf(",") + 1, arrayStr.indexOf(",", 6));
        console.log(host, clientSocket.id)
        console.log(host == clientSocket.id)
        console.log(races[key].length)
        if(host == clientSocket.id && races[key].length > 3){
          console.log('h')
          console.log(races[key][2].toString())
          io.to(races[key][2].toString()).emit("newHost");
        }

      }
    }

    userLeft(clientSocket.id)

    if(emitKey != "" && emitKey in races){
      io.in(emitKey).emit("userListUpdate", races[emitKey].toString())
    }

    console.log(clientSocket.id +  " left")
    // io.in(data).emit("userListUpdate", races[data].toString())
  });

});

function createNewRace(id, socketId){
  races[id] = [false]
  joinRace(id, socketId)
}

function joinRace(id, socketId){ 
  for (var key in races){
      if(races[key].includes(socketId)){
        removeFromArray(races[key], socketId)
      }
  }

  races[id].push(socketId) 

  for (var key in races){
    if(races[key].toString() == "false" || races[key].toString() == "true"){
      delete races[key]
    }
  }
}

function removeFromArray(array, item){
  const index = array.indexOf(item);
  if (index > -1) {
    array.splice(index, 1);
  }
}

function userLeft(socketId){
  for (var key in races){
    if(races[key].includes(socketId)){
      removeFromArray(races[key], socketId)
    }
  }


  for (var key in races){
    console.log(key)
    if(races[key].toString() == "false" || races[key].toString() == "true"){
      console.log(key)
      delete races[key]
    }
  }
}