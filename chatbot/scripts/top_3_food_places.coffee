# Description:
#   When prompted, gives suggestions for the top 3 food places in a certain location with the location being in the format
#   city name, full state name i.e. "Los Angeles, California"
# Command:
#   @chatty_chat_bot give me top food places for <location>
#   i.e. @chatty_chat_bot give me top food places for los angeles, california
#

module.exports = (robot) ->

  robot.hear /give me top food places for (.*)/i, (res) ->
    tweetID = Math.floor((Math.random() * 500) + 1)
    query = res.match[1].toLowerCase().replace(',', '')
    query = query.replace(' ', '%20')
    # cityAndState = query.split" "
    # city = cityAndState[0]
    # state = cityAndState[1]
    googleURL = "http://maps.googleapis.com/maps/api/geocode/json?address=#{query}&sensor=false"
    res.http(googleURL)
      .headers(Accept: 'application/json')
      .get() (err, httpRes, body) ->
        locationData = JSON.parse body
        latitude = locationData['results'][0]['geometry']['location']['lat']
        longitude = locationData['results'][0]['geometry']['location']['lng']
        auth = 'Bearer 0F3JznLA0qsIEAU0FRfrhuX8sJLnyHGT2Fsye18cZ50eujlFbiPSCHYbAIkVM6dv6EpZVyev_kLIqg1NwVsHf5UoLTbX9d_klxBooyOFlWNv6svWWdXB39_MFaXdWHYx'
        yelpURL = "https://api.yelp.com/v3/businesses/search?term=food&price=1&limit=3&latitude=#{latitude}&longitude=#{longitude}"
        res.http(yelpURL)
          .headers(Authorization: auth, Accept: 'application.json')
          .get() (err, httpRes, body) ->
            businessesData =  JSON.parse body
            place1 = businessesData['businesses'][0]['name']
            place2 = businessesData['businesses'][1]['name']
            place3 = businessesData['businesses'][2]['name']
            res.send "My top 3 suggestions are: #{place1}, #{place2}, #{place3} (id: #{tweetID})"
