
module.exports =
  getUserId: (req) ->
    elevatedTrust = req._route?['elevated-trust']
    userHeaderName = req._route?['user-header']
    userHeader = req.headers[userHeaderName] if userHeaderName
    authUser = req._auth?.access_token?.user_id

    (authUser or userHeader)?.toLowerCase()
