// where do the emojis go?
var container
// which emoji do i show?
var emoji = ['💰', '💵', '💸', '⚡️', '🎉', '🤑']
var circles = []
var animationId
var previousAnimationId = 0

/* stupid hack */
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

function togglePromo() {
  if (!animationId) {
    startEmoji()
    $('.retrofees__container').fadeToggle()
    $('html, body').scrollTop(0)
  } else {
    stopEmoji()
    animationId = null
    $('.retrofees__container').fadeToggle()
  }
}

// create 160 emoji to fall down the screen

$(document).on('turbolinks:load', function() {
  $('#retrofees__promo-modal-trigger').click(function(event) {
    togglePromo()
  })

  var innerText = $('#retrofees__moneyFieldHere').text()

  var money = $('#retrofees__transaction').children()[2].innerText
  var eventName = $('span[style*="font-size: 3rem"]')[0].innerText

  $('#retrofees__moneyFieldHere').text(
    innerText.replace('%money%', money).replace('%event%', eventName)
  )

  $('#retrofees__all').click(function() {
    if (animationId > previousAnimationId + 100) {
      togglePromo()
    }
  })

  if (!window.localStorage.getItem('wiggleReimbursement')) {
    window.localStorage.setItem('wiggleReimbursement', false)
    $('#retrofees__transaction').addClass('animated tada delay-2s')
  }

  $('.retrofees__close_button').click(function() {
    togglePromo()
  })

  container = document.getElementById('retrofees__emojis')

  for (var i = 0; i < 20; i++) {
    addCircle(
      i * 150,
      [10 + 0, 300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 160,
      [10 + 0, -300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 170,
      [10 - 200, -300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 180,
      [10 + 200, 300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 190,
      [10 - 400, -300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 200,
      [10 + 400, 300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 210,
      [10 - 600, -300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
    addCircle(
      i * 220,
      [10 + 600, 300],
      emoji[Math.floor(Math.random() * emoji.length)]
    )
  }
})

// push circle into array (method called above)
function addCircle(delay, range, color) {
  setTimeout(function() {
    var c = new Circle(
      range[0] + Math.random() * range[1],
      Math.random() * (Math.random() * 15) - 150,
      color,
      {
        x: -0.15 + Math.random() * 0.3,
        y: 1 + Math.random() * 1
      },
      range
    )
    circles.push(c)
    // do it after a delay
  }, delay)
}

function Circle(x, y, c, v, range) {
  var _this = this
  this.x = x
  this.y = y
  this.color = c
  this.v = v
  this.range = range
  this.element = document.createElement('span')
  /*this.element.style.display = 'block';*/
  this.element.style.opacity = 0
  this.element.style.position = 'absolute'
  this.element.style.fontSize = '36px'
  this.element.style['z-index'] = '1'
  this.element.innerHTML = c
  container.appendChild(this.element)

  this.update = function() {
    if (_this.y > 900) {
      _this.y = Math.random() * 4
      _this.x = _this.range[0] + Math.random() * _this.range[1]
    }
    _this.y += _this.v.y
    _this.x += _this.v.x
    this.element.style.opacity = 1
    this.element.style.transform =
      'translate3d(' + _this.x + 'px, ' + _this.y + 'px, 0px)'
    this.element.style.webkitTransform =
      'translate3d(' + _this.x + 'px, ' + _this.y + 'px, 0px)'
    this.element.style.mozTransform =
      'translate3d(' + _this.x + 'px, ' + _this.y + 'px, 0px)'
  }
}

function animate() {
  for (var i in circles) {
    circles[i].update()
  }
  animationId = requestAnimationFrame(animate)
}

function startEmoji() {
  animationId = requestAnimationFrame(animate)
}

function stopEmoji() {
  previousAnimationId = animationId
  cancelAnimationFrame(animationId)
}
