# Description:
#   When asked, gives a description of who chatty_chat_bot is.
#
# Command:
#   @chatty_chat_bot who are you?
#

module.exports = (robot) ->

  robot.respond /who are you?/i, (res) ->
    res.send "I'm a chatbot. Who are you??";
