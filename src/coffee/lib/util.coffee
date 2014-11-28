formatTime = (datetime) ->
  return null unless datetime.getDate
  minutes = datetime.getMinutes()
  minutes = "0" + minutes if minutes < 10
  datetime.getHours() + ":" + minutes

module.exports = {
  formatTime: formatTime
}
