# Description:
#   When prompted, gives suggestions for a certain category of food in a certain location with the location being in the format
#   city name, full state name i.e. "Los Angeles, California"
# Command:
#   @chatty_chat_bot give me recommendations for <type_of_food> in <location>
#   i.e. @chatty_chat_bot give me the hours for coffee in los angeles, california
#


module.exports = (robot) ->

  robot.hear /give me recommendations for (.*) in (.*)/i, (res) ->
    tweetID = Math.floor((Math.random() * 500) + 1)
    searchTerm = res.match[1].toLowerCase()
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
        yelpURL = "https://api.yelp.com/v3/businesses/search?term=#{searchTerm}&price=1&limit=3&latitude=#{latitude}&longitude=#{longitude}"
        res.http(yelpURL)
          .headers(Authorization: auth, Accept: 'application.json')
          .get() (err, httpRes, body) ->
            businessesData =  JSON.parse body
            place1 = businessesData['businesses'][0]['name']
            place2 = businessesData['businesses'][1]['name']
            place3 = businessesData['businesses'][2]['name']
            res.send "My top 3 suggestions for #{searchTerm} in #{locationWithCaps}are: #{place1}, #{place2}, #{place3} (id: #{tweetID})"
