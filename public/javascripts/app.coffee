$ ->
  $('.photos').imagesLoaded ->
    $('.loading').hide()
    $('.photos').masonry
      itemSelector: '.brick'



  opts = {
    lines: 9,
    length: 7,
    width: 10,
    radius: 34,
    corners: 1,
    rotate: 37,
    color: '#FFFFFF',
    speed: 1,
    trail: 15,
    shadow: false,
    hwaccel: false,
    className: 'spinner',
    zIndex: 2e9,
    top: 50,
    left: 'auto'
  };
  $('.loading').spin(opts)
