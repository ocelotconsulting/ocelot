module.exports =
  getExpirationSeconds: (auth) =>
    if auth and auth.obtained_on and auth.expires_in
      tokenAgeInSeconds = (new Date().getTime() - (auth.obtained_on)) / 1000
      ttlSeconds = auth.expires_in - Math.round(tokenAgeInSeconds)
      ttlSeconds = 0 if ttlSeconds < 0
      ttlSeconds
    else
      0