function onRequest(request, response, modules){
  var room = request.body.room._id;
  var username = request.username;

  //Setup pubnub
  var pubnub = modules.pubnub.init({
    publish_key   : "pub-c-54950570-ed66-4f98-8b3b-d101960f63ec",
    subscribe_key : "sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe"
  });

  //Remove the specified participant
  modules.collectionAccess.collection('room').update({
    _id: room
  },{
    $pull: {"participants": {"_id":username } }
  }, function(err){
    if(err){
      response.complete(500)
    }else{

      //Notify everyone in the room that the person has left
      pubnub.publish({
        channel: room,
        message: {
          type: 'left-room',
          userId: username,
          roomId: room
        },
        callback: function() {
          response.complete(200)
        },
        error: function(e) {
          modules.logger.info(e);
          response.complete(500);
        }
      });
    }
  });
}