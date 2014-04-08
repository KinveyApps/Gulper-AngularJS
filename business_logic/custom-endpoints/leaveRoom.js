function onRequest(request, response, modules){
  var room = request.body.room._id;
  //Setup pubnub
  var pubnub = modules.pubnub.init({
    publish_key   : "pub-c-54950570-ed66-4f98-8b3b-d101960f63ec",
    subscribe_key : "sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe"
  });

  //Get the user ID
  modules.collectionAccess.collection('user').findOne({username: request.username}, {}, function(err, user){
    var userId = user._id;
    //Remove the specified participant
    modules.collectionAccess.collection('room').update({
      _id: modules.collectionAccess.objectID(room)
    },{
      $pull: {"participants": {"_id": userId.toString() } }
    }, {}, function(err){
      if(err){
        modules.logger.info(err);
        response.complete(500)
      }else{

        modules.logger.info(room);

        //Notify everyone in the room that the person has left
        pubnub.publish({
          channel: room,
          message: JSON.stringify({
            type: 'left-room',
            userId: userId,
            roomId: room
          }),
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
  });
}