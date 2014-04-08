function onPreSave(request, response, modules){
  if(!request.body.room || !request.body.text){
    response.complete(400,{
      "error":{
        "message":"MissingRequiredParameters",
        "description":"Room and text is be required"
      }
    });
  }else{
    response.continue();
  }
}