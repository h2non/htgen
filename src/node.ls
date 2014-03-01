{ extend, is-string, is-object, is-array } = require './helpers'
Generator = require './generator'

exports = module.exports = class Node

  @create = ->
    instance = Node:: |> Object.create
    Node.apply instance, &
    instance

  ->
    @tag = 'div'
    @self-closed = no
    @attributes = {}
    @child-nodes = []
    @apply-args ...

  apply-args: (tag, ...child) ->
    if tag |> is-node
      tag |> @child
    else if tag |> is-object
      tag |> @child
    else if tag |> is-string
      { tagName, attributes, self-closed } = tag |> parse-tag
      @tag = tagName if tagName
      @self-closed = self-closed if self-closed
      if attributes
        attributes['class'] |> @concat-attr 'class', _
        if attributes.id
          @attributes <<< id: attributes.id

    child.for-each ~>
      if it |> is-node
        it |> @push
      else if it |> is-string
        it |> @push
      else if (it |> is-array) and it[0] |> is-node
        it.for-each ~> it |> @child
      else if (it |> is-object) or (it |> is-array)
        it |> @attr

  push: ->
    if it |> is-string
      it |> @child-nodes.push
    else if it |> is-node
      it.parent = @
      it |> @child-nodes.push
    @

  child: ->
    if it |> is-node
      it |> @push
    else if it |> is-string
      Node.create ... |> @push
    @

  c: -> @child ...

  cchild: ->
    @child ...
    @child-nodes.slice -1

  cc: -> @cchild ...

  attr: (name, value) ->
    if name |> is-object
      name |> extend @attributes, _
    else if name |> is-array
      name.for-each ~> 
        it |> @attr if it |> is-object
        @attributes <<< (it): null if it |> is-string
    else if name |> is-string
      @attributes <<< (name): value
    @

  a: -> @attr ...

  concat-attr: (name, value) -> 
    if name and value
      if name |> @attributes.has-own-property
        @attributes['class'] += ' ' + attributes['class']
      else
        @attr ...
    @

  last: -> @child-nodes.slice -1

  l: -> @last ...

  has-parent: -> 'parent' |> @has-own-property

  has-child: -> @child-nodes.length > 0

  render: (options) -> new Generator @, options .render!

  r: -> @render ...

  to-string: -> @render ...


is-node = -> it instanceof Node

is-self-closed = -> it.slice(-1) is '!'

remove-not = -> it.slice 0, -1 

parse-tag = (tag) ->
  result = {}
  self-closed = no

  if (tag = tag.trim!) |> is-self-closed
    tag = tag |> remove-not
    result <<< self-closed: yes

  [ head, id ] = tag.split '#'
  [ tag-name, ...classes ] = head.split '.'

  if tag-name
    result <<< tag-name: tag-name = tag-name.trim!

  if id or classes
    attrs = result.attributes = {}
    attrs <<< id: id.trim! if id
    attrs <<< 'class': (classes.join ' ').trim! if classes

  result
