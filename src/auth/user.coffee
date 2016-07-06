
module.exports =
  getUserId: (req) ->
    getAuthUser = () ->
      req._auth?.access_token?.user_id

    getUserHeader = () ->
      if req._route
        route = req._route
        elevatedTrust = route['elevated-trust'] and
          route['require-auth'] and
          req._route?['client-whitelist']?.length > 0 and
          route['user-header']
        req.headers[route['user-header']] if elevatedTrust

    (getAuthUser() or getUserHeader())?.toLowerCase()
