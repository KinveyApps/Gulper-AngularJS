function onPostSave(request, response, modules){
  modules.collectionAccess
    .collection('user')
    .findOne({_id: modules.collectionAccess.objectID(response.body.from._id)}, {}, function(err, obj){
      if(err){
        modules.logger.fatal(err);
        response.complete(500);
      }else if(!obj){
        modules.logger.error('Cant find user object.');
        response.complete(404)
      }else{
        userObj = {
          _id: obj._id,
          _socialIdentity:{
            facebook: {
              name: obj._socialIdentity.facebook.name,
              id: obj._socialIdentity.facebook.id
            }
          }
        }
        response.body.from = userObj;

        //Setup pubnub
        var pubnub = modules.pubnub.init({
          publish_key   : "pub-c-54950570-ed66-4f98-8b3b-d101960f63ec",
          subscribe_key : "sub-c-ea5fd726-be91-11e3-b6e0-02ee2ddab7fe"
        });

        // Notify everyone in the room
        pubnub.publish({
          channel: response.body.room._id,
          message: JSON.stringify(response.body),
          callback: function(datas) {

            //Figure out who should be notified but is not here!
            //First, get the room info.
            modules.collectionAccess
              .collection('room')
              .findOne({_id: modules.collectionAccess.objectID(response.body.room._id)}, {}, function(err, obj){
                if(err || !obj){
                  //Unable to do anything, whatever they will get the messages later
                  response.continue();
                  return;
                }else{
                  //We have a room! Let's loop through and create a user ID hash
                  var hash = {};
                  for(var i=0;i<obj.participants.length;i++){
                    hash[obj.participants[i]._id] = false;
                  }

                  //Now figure out who is here.
                  pubnub.here_now({
                    channel: response.body.room._id,
                    callback: function(rtn){
                      //Create a hash lookup
                      for(var i=0;i<rtn.uuids.length;i++){
                        delete hash[rtn.uuids[i]];
                      }

                      // Now get an array of people not here
                      var notHere = Object.keys(hash);
                      //For each person we should notify them if they want to be notified

                      var notificationCount = notHere.length;

                      var notify = function(userId){
                        modules.logger.info('Need to notify: '+userId);

                        //Handle finalizing the request.
                        notificationCount--;
                        if(notificationCount == 0){
                          response.continue();
                        }
                      };

                      for(var i=0;i<notHere.length;i++){
                        notify(notHere[i])
                      }
                    }
                  })
                }
              })
          },
          error: function(e) {
            modules.logger.info(e);
            response.complete(500);
          }
        });
      }
    })
}