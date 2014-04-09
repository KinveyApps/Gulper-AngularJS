function onPostSave(request, response, modules){
  var pubnub = modules.pubnub.init({
    publish_key   : "pub-c-54950570-ed66-4f98-8b3b-d101960f63ec",
    subscribe_key : "sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe"
  });

  if(!request.entityId){
    modules.logger.info('Room creation');
    //This is a new record
    var publishCount = 0;
    var publish = function(userId){
      pubnub.publish({
        channel: userId,
        message: {type: 'new-room', id: response.body._id},
        callback: function(datas) {
          publishCount++;
          if(publishCount-1 == response.body.participants.length){
            response.continue();
          }
        },
        error: function(e) {
          modules.logger.info(e);
          response.complete(500);
        }
      });
    };

    for(var i=0;i<response.body.participants.length;i++){
      publish(response.body.participants[i]._id)
    }
  }else{
    //This record has been updated, we should just trigger rename
    pubnub.publish({
      channel: request.entityId,
      message: JSON.stringify({type: 'room-renamed', name: response.body.name}),
      callback: function() {
        response.continue();
      },
      error: function(e) {
        modules.logger.info(e);
        response.complete(500);
      }
    });
  }
}
