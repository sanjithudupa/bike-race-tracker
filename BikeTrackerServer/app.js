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

    if(data in races){
      joinRace(data, clientSocket.id)
    }else{
      createNewRace(data, clientSocket.id)
      joinState = "create"
    }

    clientSocket.emit("youJoinedRace", joinState, races[data].toString())
    io.in(data).emit("userListUpdate", races[data].toString())
    // console.log(races[data])

    console.log(clientSocket.id + " joined " + data)
  });

  clientSocket.on('disconnect', function(){
    delete users[clientSocket.id]
    userLeft(clientSocket.id)
    console.log(clientSocket.id +  " left")
  });

});

function createNewRace(id, socketId){
  races[id] = []
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
    let strKey = races[key].toString()
    if(strKey == ""){
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
    let strKey = races[key].toString()
    if(strKey == ""){
      delete races[key]
    }
  }
}