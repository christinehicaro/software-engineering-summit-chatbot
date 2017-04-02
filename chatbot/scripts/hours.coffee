# Description:
#   When prompted, gives the hours for a business in a certain location with the location being in the format
#   city name, full state name i.e. "Los Angeles, California"
# Command:
#   @chatty_chat_bot give me the hours for <business_name> in <location>
#   i.e. @chatty_chat_bot give me the hours for portillo's in countryside, illinois
#

module.exports = (robot) ->

  robot.hear /give me the hours for (.*) in (.*)/i, (res) ->
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
              todayHoursStart = businessData['hours'][0]['open'][day]['start'].toString()
              todayHoursEnd = businessData['hours'][0]['open'][day]['end'].toString()
              todayHoursStart = todayHoursStart.substr(0,2) + ":" + todayHoursStart.substr(2)
              todayHoursEnd = todayHoursEnd.substr(0,2) + ":" + todayHoursEnd.substr(2)
              res.send "Today's hours for #{res.match[1]} in #{locationWithCaps}are #{todayHoursStart} - #{todayHoursEnd} (id: #{tweetID})"
              # place1 = businessesData['businesses'][0]['name']
              # place2 = businessesData['businesses'][1]['name']
              # place3 = businessesData['businesses'][2]['name']
              # res.send "My top 3 suggestions are: #{place1}, #{place2}, #{place3}"
