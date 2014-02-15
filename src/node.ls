{ extend, is-string, is-object, is-array } = require './helpers'
Generator = require './generator'

exports = module.exports = class Node

  @create = ->
    instance = Node:: |> Object.create
    Node.apply instance, &
    instance

  ->
    @tag = 'div'
    @attributes = {}
    @child-nodes = []
    @apply-args ...

  apply-args: (tag, ...child) ->
    if tag |> is-node
      tag |> @child
    else if tag |> is-object
      tag |> @child
    else if tag |> is-string
      { tagName, attributes } = tag |> parse
      @tag = tagName if tagName
      if attributes
        attributes['class'] |> @concat-attr 'class', _
        if attributes.id
          @attributes <<< id: attributes.id

    child.for-each ~>
      if it |> is-node
        it |> @push
      else if it |> is-string
        it |> @push
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

  has-parent: -> 'parent' |> @has-own-property

  render: (options) -> new Generator @, options .render!

  r: -> @render ...

  to-string: -> @render ...


is-node = -> it instanceof Node

parse = ->
  result = {}
  [ head, id ] = it.trim!split '#'
  [ tagName, ...classes ] = head.split '.'

  result <<< tagName: tagName.trim! if tagName
  if id or classes
    attrs = result.attributes = {}
    attrs <<< id: id.trim! if id
    attrs <<< 'class': (classes.join ' ').trim! if classes

  result
