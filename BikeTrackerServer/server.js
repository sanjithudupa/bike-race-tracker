const express = require('express');
const app = express();
const server = app.listen(3000, () => { console.log('listening on *:3000'); });
const io = require('socket.io')(server);

let users = {}
let races = {}
let gotPositions = {}

app.get('/', (req, res) => {
  res.redirect('/rooms')
});

app.get('/rooms', (req, res) => {
  // for (var key in races) {
  //   // check if the property/key is defined in the object itself, not in parent
  //   if (races.hasOwnProperty(key)) {           
  //       console.log(key, races[key]);
  //   }
  // }
  res.send(races)
});

app.get('/users', (req, res) => {
  // for (var key in races) {
  //   // check if the property/key is defined in the object itself, not in parent
  //   if (races.hasOwnProperty(key)) {           
  //       console.log(key, races[key]);
  //   }
  // }
  res.send(users)
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
    // let joinIndex = 0

    if(races[data] != null && races[data].toString().substring(0,4) == "true"){
      clientSocket.emit("raceAlreadyStarted")
    }else{
      if(data in races && races[data] != [false] && races[data] != [true]){
        // joinIndex = races[data].length
        joinRace(data, clientSocket.id)
      }else{
        createNewRace(data, clientSocket.id)
        joinState = "create"
      }

      clientSocket.emit("youJoinedRace", joinState, races[data].toString(), clientSocket.id)
      let userNames = []
      // for(var user in races[data]){
      //   userNames.append(users[user])
      // }
      let firstDone = false;
      
      for(var user in races[data]){
        if(firstDone){
          userNames.push(users[races[data][user]])
        }else{
          firstDone = true
        }
      }
        
      console.log(userNames)

      io.in(data).emit("userListUpdate", races[data].toString(), userNames.toString())
      // io.in(data).emit("userNamesUpdate", userNames.toString())

      console.log(races[data])
      // console.log(races[data])

      console.log(clientSocket.id + " joined " + data)
    }

    
  });

  clientSocket.on('startRace', (data) =>{
    races[data][0] = true;
    io.in(data).emit("startRace");
  });

  clientSocket.on('positionUpdate', (data) => {
    console.log('posupdate with ' + data + ' from ' + clientSocket.id)
    // let clientIndex = 0
    // console.log(races[data[1]])
    if(races[data[1]] != null && races[data[1]].toString().includes(clientSocket.id)){
    //   clientIndex = races[data[1]].indexOf(clientSocket)
      if(gotPositions[data[1]]){
        gotPositions[data[1]] += 1
      }else{
        gotPositions[data[1]] = 1
      }

      clientSocket.to(data[1]).emit("positionUpdate", data[0].toString(), clientSocket.id.toString());

      console.log(gotPositions[data[1]])
      if(gotPositions[data[1]] >= (races[data[1]].length-1)){
        io.in(data[1]).emit("updatePositionLabels")
        gotPositions[data[1]] = 0
      }
    }
  });

  clientSocket.on('stopRace', (data) =>{
    races[data][0] = false;
    gotPositions[data[1]] = null
    io.in(data).emit("stopRace");
  });

  clientSocket.on('setEndpoint', (data) =>{
    let dstring = data.toString()
    console.log(dstring)
    let cindex = dstring.indexOf(",");
    io.in(dstring.substring(0, cindex)).emit("setEndpoint", dstring.substring(cindex + 1));
    console.log("sent" + dstring.substring(cindex + 1) + "to" + dstring.substring(0, cindex))
  });

  clientSocket.on('stopRecording', function(){
    clientSocket.emit('stopRecording')
  });

  clientSocket.on('leaveRace', function(){
    let emitKey = ""

    for (var key in races){
      if(races[key].includes(clientSocket.id)){
        emitKey = key;
        let arrayStr = races[key].toString()
        let host = arrayStr.substring(arrayStr.indexOf(",") + 1, arrayStr.indexOf(",", 6));
        if(host == clientSocket.id && races[key].length >= 3){
          io.to(races[key][2].toString()).emit("newHost");
          console.log("new host")
        }
      }
    }

    userLeft(clientSocket.id)

    if(emitKey != "" && emitKey in races){
      io.in(emitKey).emit("userListUpdate", races[emitKey].toString())
    }

    console.log(clientSocket.id +  " left")
  });

  clientSocket.on('disconnect', function(){
    delete users[clientSocket.id]
    let emitKey = ""

    for (var key in races){
      if(races[key].includes(clientSocket.id)){
        emitKey = key;
        let arrayStr = races[key].toString()
        let host = arrayStr.substring(arrayStr.indexOf(",") + 1, arrayStr.indexOf(",", 6));
        if(host == clientSocket.id && races[key].length >= 3){
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
