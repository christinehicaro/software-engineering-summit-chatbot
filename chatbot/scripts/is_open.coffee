# Description:
#   When asked, tells the user whether or not a certai business in a certain location with the location in the format
#   city name, full state name i.e. "Los Angeles, California"
# Command:
#   @chatty_chat_bot is <business_name> in <location> open?
#   i.e. @chatty_chat_bot is portillo's in countryside, illinois open?
#

module.exports = (robot) ->

  robot.hear /is (.*) in (.*) open/i, (res) ->
    tweetID = Math.floor((Math.random() * 500) + 1)
    name = res.match[1].toLowerCase().replace(' ', '%20')
    location = res.match[2]
    locationMod = location.toLowerCase().replace(',', '').replace(' ', '%20')
    locationList = location.split " "
    index = 0
    locationWithCaps = ""
    for word in locationList
      locationWithCaps += word[0].toUpperCase() + word.substr(1) + " "
      index++
    googleURL = "http://maps.googleapis.com/maps/api/geocode/json?address=#{locationMod}&sensor=false"
    res.http(googleURL)
      .headers(Accept: 'application/json')
      .get() (err, httpRes, body) ->
        locationData = JSON.parse body
        latitude = locationData['results'][0]['geometry']['location']['lat']
        longitude = locationData['results'][0]['geometry']['location']['lng']
        auth = 'Bearer 0F3JznLA0qsIEAU0FRfrhuX8sJLnyHGT2Fsye18cZ50eujlFbiPSCHYbAIkVM6dv6EpZVyev_kLIqg1NwVsHf5UoLTbX9d_klxBooyOFlWNv6svWWdXB39_MFaXdWHYx'
        yelpURL = "https://api.yelp.com/v3/businesses/search?term=#{name}&limit=1&latitude=#{latitude}&longitude=#{longitude}"
        res.http(yelpURL)
          .headers(Authorization: auth, Accept: 'application.json')
          .get() (err, httpRes, body) ->
            businessData = JSON.parse body
            id = businessData['businesses'][0]['id']
            businessURL = "https://api.yelp.com/v3/businesses/#{id}"
            date = new Date()
            day = date.getDay()
            res.http(businessURL)
            .headers(Authorization: auth, Accept: 'application.json')
            .get() (err, httpRes, body) ->
              businessData =  JSON.parse body
              isClosed = businessData['is_closed']
              if isClosed
                res.send "No, it's closed :'( (id:#{tweetID})"
              else
                res.send "Yup, it's open! (id:#{tweetID})"
