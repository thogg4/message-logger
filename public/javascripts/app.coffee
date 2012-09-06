message = 
  "<div class='row'>"+
    "<div class='one columns'>"+
      "{{time}}"+
    "</div>"+
    "<div class='six columns'>"+
      "{{message}}"+
    "</div>"+
    "<div class='one columns'>"+
      "{{author}}"+
    "</div>"+
  "</div>"


getMessages = (date) ->
  if !window.messages
    data = $.getJSON '/get/json/messages', (data) ->
      window.messages = data


  else
    return window.messages

$ ->
  $('.filter-messages').keyup ->
    if $(this).val().length >= 3
      console.log 'messages:'
      console.log getMessages()
