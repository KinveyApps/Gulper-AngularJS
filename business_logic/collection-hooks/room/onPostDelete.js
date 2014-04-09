function onPostDelete(request, response, modules){
  var pubnub = modules.pubnub.init({
    publish_key   : "pub-c-54950570-ed66-4f98-8b3b-d101960f63ec",
    subscribe_key : "sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe"
  });
  //This record has been deleted, notify people on the room that is gone!
  pubnub.publish({
    channel: request.entityId.toString(),
    message: JSON.stringify({type: 'room-deleted'}),
    callback: function() {
      modules.logger.info('Room deleted');
      modules.logger.info(request.entityId.toString());
      response.continue();
    },
    error: function(e) {
      modules.logger.info(e);
      response.complete(500);
    }
  });
}
