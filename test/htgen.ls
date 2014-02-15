{
  ht
  expect
} = require './lib/helper'

describe 'htgen', ->

  describe 'API', (_) ->

    it 'should expose a function object', ->
      expect ht .to.be.a 'function'

    it 'should expose the Node class', ->
      expect ht.Node .to.be.a 'function'

    it 'should expose the Generator class', ->
      expect ht.Generator .to.be.a 'function'
       
  describe 'create', (_) ->

    it 'should create a "div" tag', ->
      expect ht('div').tag .to.be.equal 'div'

    it 'should create a node with id attribute', ->
      expect ht('div', { id: 'my-id' }).attributes.id .to.be.equal 'my-id'

    it 'should create a node with class attribute', ->
      expect ht('div', { 'class': 'box main' }).attributes['class'] .to.be.equal 'box main'

  describe 'child nodes', (_) ->

    it 'should create a child node via ht()', ->
      expect ht('div', ht('p')).child-nodes[0].tag .to.be.equal 'p'

    it 'should create a child node via child()', ->
      expect ht('div').child('p').child-nodes[0].tag .to.be.equal 'p'

    it 'should create a child node with id attribute', ->
      expect ht('div').child('p', { id: 'my-id' }).child-nodes[0].attributes.id .to.be.equal 'my-id'

  describe 'tag parser', (_) ->

    it 'should parse "div" as tag', ->
      expect ht('div').tag .to.be.equal 'div'
    
    it 'should parse a "cls" as css class', ->
      expect ht('div.cls').attributes['class'] .to.be.equal 'cls'

    it 'should use a div tag by default using dot notation', ->
      expect ht('.cls').tag .to.be.equal 'div'
      expect ht('.cls').attributes['class'] .to.be.equal 'cls'

    it 'should use a div tag by default using sharp notation', ->
      expect ht('#id').tag .to.be.equal 'div'
      expect ht('#id').attributes.id .to.be.equal 'id'

    it 'should parse a "cls.another-class.final" as css classes', ->
      expect ht('div.cls.another-class.final').attributes['class'] 
        .to.be.equal 'cls another-class final'

    it 'should parse a "my-id" as id attribute', ->
      expect ht('div#my-id').attributes.id .to.be.equal 'my-id'

    it 'should parse a "cls.another-class#my-id" as class and id attributes', ->
      expect ht('div.cls.another-class#my-id').tag .to.be.equal 'div'
      expect ht('div.cls.another-class#my-id').attributes.id .to.be.equal 'my-id'
      expect ht('div.cls.another-class#my-id').attributes['class'] .to.be.equal 'cls another-class'

    describe 'formatting', (_) ->

      it 'should parse " div .cls.another-class# my-id " properly', ->
        expect ht(' div .cls.another-class# my-id ').tag .to.be.equal 'div'
        expect ht(' div .cls.another-class# my-id ').attributes.id .to.be.equal 'my-id'
        expect ht(' div .cls.another-class# my-id ').attributes['class'] .to.be.equal 'cls another-class'

  describe 'code generator', (_) ->

    it 'should generate a div', ->
      expect ht('div').text! .to.be.equal '<div></div>'

    it 'should generate a div with class attribute', ->
      expect ht('.main.text').text! .to.be.equal '<div class="main text"></div>'

    it 'should generate a div with id attribute', ->
      expect ht('#my-id').text! .to.be.equal '<div id="my-id"></div>'

    it 'should generate a div with style attribute', ->
      expect ht('div', { id: 'main', 'style': { color: 'red' } }).text! 
        .to.be.equal '<div id="main" style="color: red"></div>'

    it 'should generate a div with style attribute list', ->
      expect ht('div', { id: 'main', 'style': { color: 'red', float: 'left' } }).text! 
        .to.be.equal '<div id="main" style="color: red; float: left"></div>'

    it 'should create a node and use toString() method', ->
      expect ht('p', 'this is a ' + ht('a', { href: 'http://i.am' }, 'link')).render() 
        .to.be.equal '<p>this is a <a href="http://i.am">link</a></p>'

    describe 'options', (_) ->

      it 'should generate a well indented code', ->
        expect ht('div', { 'style': { color: 'red' } }, ht('p', 'text')).render { pretty: yes }
          .to.be.equal '<div style="color: red">\n  <p>text</p>\n</div>'
      
      xit 'should generate a well indented code', ->
        expect ht('div', { 'style': { color: 'red' } }, ht('p', 'text'), ht('a', ht('span.subtitle'))).render { pretty: yes }
          .to.be.equal '<div style="color: red"><p>text</p></div>'
