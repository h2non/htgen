htgen = ->
  instance = Object.create Node::
  Node.apply instance, &
  instance

class Node

  (tag, ...child) ->

    @tag = 'div'
    @attributes = {}
    @child-nodes = []

    if tag instanceof Node
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

    if child |> is-array
      child.for-each ~>
        if it instanceof Node
          it |> @child
        else if it |> is-string
          it |> @child-nodes.push
        else if it |> is-object
          it |> @attr

  child: ->
    if it instanceof Node
      it |> @push
    else if it |> is-string
      htgen ... |> @push
    @

  c: -> @child ...

  push: ->
    if it instanceof Node
      it.parent = @
      it |> @child-nodes.push
    @

  cchild: ->
    @child ...
    @child-nodes.slice -1

  cc: -> @cchild ...

  attr: (name, value) ->
    if name |> is-object
      name |> extend @attributes, _
    else if name |> is-string
      @attributes <<< (name): value
    @

  a: -> @attrs ...

  concat-attr: (name, value) -> 
    if name and value
      if name |> @attributes.has-own-property
        @attributes['class'] += ' ' + attributes['class']
      else
        @attr ...
    @

  render: (options) ->
    new Generator @, options .text!

  r: -> @render ...

  text: -> @render ...

  to-string: -> @render ...


class Generator

  const EOL = '\n'
  const TAB = '\t'
  const tag-open-regex = /^(<[^>]+>)([\s|\t]+)?</
  const tag-close-regex = />([\s|\t]+)?(<\/[^<]+>$)/

  options:
    pretty: no
    size: 0
    indent: 2
    tabs: no

  (node, options) ->
    
    if not (node instanceof Node)
      throw new TypeError 'First argument must be an instance of Node'

    @node = node
    options |> extend @options, _

  render-attrs: ->
    buf = []
    for own name, value of @node.attributes when name
      tmp = " #{name}"
      if value |> is-object
        styles = []
        for own id, prop of value then "#{id}: #{prop}" |> styles.push 
        value = styles.join '; '
      tmp += "=\"#{value}\"" if value
      tmp |> buf.push
    buf.join ''

  render-body: ->
    buf = []
    @node.child-nodes.for-each ~>
      if it |> is-string
        it |> buf.push
      else if it instanceof Node
        it.render @options |> buf.push
    buf

  indent: ->
    if not @options.tabs
      value = Array(@options.indent + 1).join ' '
    else
      value = TAB
    value

  apply-indent: (body = []) ->
    if body
      indent = @indent!
      
      body.for-each (str, line) ~>
        indent = Array(if line is 0 then line + 2 else line + 1).join @indent!
        body[line] = "#{indent}#{str}"
      body = body.join EOL
    body

  render: ->
    body = @render-body!

    if @options.pretty and not @node.parent
      body = body |> @apply-indent
    else
      body = body.join ''
    
    text = "<#{@node.tag}#{@render-attrs!}>#{body}</#{@node.tag}>"
    if @options.pretty and body
      text = text.replace tag-open-regex, "$1#{EOL}$2<"
      if not @node.parent
        text = text.replace tag-close-regex, ">#{EOL}$2"
    text

  text: -> @render ...

  to-string: -> @render ...

#
# Helpers functions
#

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

extend = (target = {}, origin) -> 
  for own name, value of origin when value then target[name] = value
  target

to-string = Object::to-string

is-string = -> typeof it is 'string'

is-object = -> (it |> to-string.call) is '[object Object]'

is-array = -> (it |> to-string.call) is '[object Array]'

#
# Exports
#

exports = module.exports = htgen
exports.Node = Node
exports.Generator = Generator
