function onPostSave(request, response, modules){
  var facebookId = 184905775;
  var accessToken = "CAACEdEose0cBAKEOunMZBEF8FEjbEWzz6vU8FwQ7iOpo3hX04wmnGNwbOLAMG6zWX5XiueDQNMawxCsZBEZCQQwxgv0dAnMYfwweoV43feQA5QZCwp4aDXQWDAPYzzRYbQRZCGnuK6M0jX3V0zA3qiLc1iZCyQPMZBUENSSDcYAUYeCyB7itU8P36hh3wqVfUBT1ZCsGfeee4wZDZD";
  var appId = '229011427294758';
  var appSecret = '78da8b2953cc7415a772624dd231e124';

  var otherUserId = '100000592211688';
	var client = modules.xmpp.getHandle({
    jid: '-' + facebookId + '@chat.facebook.com',
    api_key: appId,
    secret_key: appSecret,
    access_token: accessToken
  });

  client.addListener('online', function(data) {
    modules.logger.info('Connected as ' + data.jid.user + '@' + data.jid.domain + '/' + data.jid.resource);
    client.send("<message to='-"+otherUserId+"@chat.facebook.com'><body>"+response.body.content+"</body></message>");
    response.continue();
  })

  client.addListener('error', function(e) {
    modules.logger.error(e)
  })
}