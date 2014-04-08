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
        var userObj = {
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

                        var completionCB = function(){
                          //Handle finalizing the request.
                          notificationCount--;
                          if(notificationCount <= 0){
                            modules.logger.error('Notified People');
                            response.continue();
                          }
                        };


                        modules.collectionAccess
                          .collection('user')
                          .findOne({_id: modules.collectionAccess.objectID(userId)}, {}, function(err, obj){
                            if(!err && obj){
                              if(!obj.notificationOrder){
                                obj.notificationOrder = ['push','email','sms','snail']
                              }

                              var processNotification = function(remainingOrder){
                                var method = remainingOrder.pop();
                                var matched = false;
                                switch(method){
                                  case 'email':
                                    if(obj.email){
                                      matched = true;
                                      modules.email.send('no-reply@gulper.me',
                                        obj.email,
                                        'You have a message waiting for you',
                                        'You have a message waiting for you at http://gulper.me/conversations/'+response.body.room._id,
                                        'no-reply@gulper.me',
                                        'You have a message waiting for you at <a href="http://gulper.me/conversations/'+response.body.room._id+'">http://gulper.me/conversations/'+response.body.room._id+'</a>'
                                      )
                                    }
                                    break;
                                  case 'sms':
                                    if(obj.phone){
                                      matched = true;
                                      var authToken = 'c9e3488d55b902aa277895e95b0c17d8';
                                      var username = 'AC4665eef92cd63a8e63c8d91112888c5a';
                                      modules.request.post({
                                        uri: 'https://api.twilio.com/2010-04-01/Accounts/AC4665eef92cd63a8e63c8d91112888c5a/Messages.json',
                                        headers: {
                                          "Authentication": 'Basic ' + new Buffer(username+':'+authToken).toString('base64')
                                        },
                                        form: {
                                          to: obj.phone,
                                          from: '+14143016918',
                                          body: 'You have a message waiting for you at http://gulper.me/conversations/'+response.body.room._id
                                        }
                                      });
                                    }
                                    break;
                                  case 'snail':

                                    if(obj.address){
                                      var username = 'test_4b8444a7a611ab770d9f440c2c50f576994';
                                      matched = true;
                                      modules.request.post({
                                        uri: 'https://api.lob.com/v1/postcards',
                                        headers:{
                                          "Authentication": 'Basic ' + new Buffer(username+':').toString('base64')
                                        },
                                        json:{
                                          name: 'Message Notification '+response.body._id,
                                          'to[name]': obj.address.name,
                                          'to[address_line1]': obj.address.address1,
                                          'to[address_city]': obj.address.city,
                                          'to[address_state]': obj.address.state,
                                          'to[address_zip]': obj.address.zip,
                                          'to[address_county]': obj.address.country,
                                          'from[name]':'Gulper',
                                          'from[address_line1]':'99 Summer Street',
                                          'from[address_city]':'Boston',
                                          'from[address_state]':'MA',
                                          'from[address_zip]':'02110',
                                          'from[address_country]':'USA',
                                          back: 'You have a message waiting for you at http://gulper.me/conversations/'+response.body.room._id
                                        }
                                      })
                                    }
                                    break;
                                }

                                if(!matched && remainingOrder.length){
                                  processNotification(remainingOrder)
                                }else{
                                  completionCB()
                                }

                              };

                              processNotification(obj.notificationOrder)
                            }
                          });
                      };

                      if(notHere.length){
                        for(var i=0;i<notHere.length;i++){
                          notify(notHere[i])
                        }
                      }else{
                        response.continue();
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