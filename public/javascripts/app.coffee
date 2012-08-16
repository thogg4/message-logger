$ ->
  $('.photos').imagesLoaded ->
    $('.photos').masonry
      itemSelector: '.brick'
