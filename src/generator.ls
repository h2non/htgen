{ extend, clone, is-string, is-object, is-array } = require './helpers'
doctypes = require './doctypes'

exports = module.exports = class Generator

  const EOL = '\n'
  const TAB = '\t'
  const default-doctype = 'html'
  const tag-open-regex = /^(<[^>]+>)([\s|\t]+)?</
  const tag-close-regex = />([\s|\t]+)?(<\/[^<]+>$)/
  const doctype-regex = /^doctype(\s+([a-z\.]+))?$/i

  defaults:
    pretty: no
    size: 0
    indent: 2
    tabs: no

  (node, options) ->
    if not (node |> is-object)
      throw new TypeError 'First argument must be an instance of Node'

    @node = node
    options = { pretty: true } if options is true
    @options = options |> extend (@defaults |> clone), _

  indent: ->
    if @options.tabs
      Array(@options.size + 1).join TAB
    else
      Array(@options.size * @options.indent + 1).join ' '

  child-indent: ->
    if @options.pretty and it |> /^</.test 
      "#{@indent!}#{it}#{EOL}" 
    else
      it

  render-attrs: ->
    buf = []
    for own name, value of @node.attributes when name
      attr = " #{name}"
      if value |> is-object 
        value = value |> @render-styles
      else if value |> is-array
        value = value.join ' '
      attr += "=\"#{value}\"" if value
      attr |> buf.push
    buf.join ''

  render-styles: ->
    buf = []
    for own id, prop of it then "#{id}: #{prop}" |> buf.push
    buf.join '; '

  render-child: ->
    body = []
    @node.child-nodes.for-each ~>
      if it |> is-string
        it |> body.push
      else if it |> is-object
        it |> @render-child-node |> body.push
    body.join ''

  render-child-node: ->
    (size: @options.size + 1)
    |> extend (@options |> clone), _ 
    |> it.render
    |> @child-indent

  node-indent: ->
    if @options.pretty 
      indent = if @options.size > 0 then @indent! else ''
      it = indent + it
        .replace tag-open-regex, "$1#{EOL}$2<"
        .replace tag-close-regex, ">#{EOL}#{indent}$2"
      it += EOL if @node.has-parent!
    it

  doctype: ->
    type = doctype-regex |> @node.tag.match
    if type and type[2]
      type[2]
    else
      default-doctype

  is-doctype: ->
    @node.tag |> doctype-regex.test

  is-closed: ->

  render: ->
    if @is-doctype!
      doctypes[@doctype!]
    else if @node.self-closed
      "<#{@node.tag}#{@render-attrs!}/>" |> @node-indent
    else
      "<#{@node.tag}#{@render-attrs!}>#{@render-child!}</#{@node.tag}>" |> @node-indent

  to-string: -> @render ...
