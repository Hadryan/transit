_ready    = true
_winready = false

Transit = {}

_.extend Transit,

  # Add an internal event system to share across everything
  # include an additional "one" value similar to jQuery to run
  # a callback once. 

  on: Backbone.Events.on
  off: Backbone.Events.off
  one: (events, callback, context)->
    callone = (args...)->
      callback(args...)
      Transit.off(events, callone, context)
    Transit.on(events, callone, context)

  get: (args...)-> Transit.cache.get(args...)
  
  manage: (model, callback)->
    manager = new Transit.Manager(model: model)
    if Transit.status is 'ready'
      manager.render()
    manager
    
  ready: (callback)-> Transit.one('ready', callback)
  
  set: (args...)-> Transit.cache.set(args...)
  status: "pending"
  trigger: Backbone.Events.trigger
  version: "0.3.0"

Transit.one 'ready', ()-> Transit.status = "ready"

# functions to be called on ready

jQuery(window).one('load', ()->
  _winready = true
  if _ready is true
    Transit.trigger("ready")
    return true
  
  # preload templates as necessary  
  counter = 0
  total   = _.size(Transit.template.preloads)
  _.each( Transit.template.preloads, (jst)->
    Transit.template.load(jst, ()->
      counter++;
      _ready = true if counter == total
      if _winready is true && _ready is true
        Transit.trigger('ready')
    )
  )
)

@Transit ||= Transit