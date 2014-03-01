require! {
  ht: '../'
  'chai'.expect
}

describe 'htgen', ->

  describe 'API', (_) ->

    it 'should expose a function object', ->
      expect ht .to.be.a 'function'

    it 'should expose the Node class', ->
      expect ht.Node .to.be.a 'function'

    it 'should expose the Generator class', ->
      expect ht.Generator .to.be.a 'function'
       
    describe 'Node', (_) ->

      it 'should create a new instance of Node class', ->
        expect new ht.Node .to.be.a 'object' .and.to.be.an.instanceof ht.Node

      it 'should expose child()', ->
        expect new ht.Node .to.have.property 'child' .that.is.a 'function'
        expect new ht.Node .to.have.property 'c' .that.is.a 'function'    

      it 'should expose cchild()', ->
        expect new ht.Node .to.have.property 'cchild' .that.is.a 'function'
        expect new ht.Node .to.have.property 'cc' .that.is.a 'function'  

      it 'should expose render()', ->
        expect new ht.Node .to.have.property 'render' .that.is.a 'function'
        expect new ht.Node .to.have.property 'r' .that.is.a 'function'

    describe 'Generator', (_) ->

      it 'should expose the Generator class', ->
        expect new ht.Generator(ht!) .to.be.an 'object' .and.to.be.an.instanceof ht.Generator

      it 'should throw a TypeError if the constructor arguments is not an object', ->
        expect (-> new ht.Generator) .to.throw TypeError

      it 'should expose render()', ->
        expect new ht.Generator ht! .to.have.property 'render' .that.is.a 'function'

  describe 'create', (_) ->

    it 'should create a "div" node', ->
      expect ht('div').tag .to.be.equal 'div'

    it 'should create a "div" node by default', ->
      expect ht().tag .to.be.equal 'div'

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

    it 'should parse a "img!" as self-closed tag', ->
      expect ht('!img').tag .to.be.equal 'img'
      expect ht('!img').self-closed .to.be.true

    it 'should parse a "!.class#id" as self-closed tag', ->
      expect ht('!.class#id').tag .to.be.equal 'div'
      expect ht('!.class#id').attributes.id .to.be.equal 'id'
      expect ht('!.class#id').attributes['class'] .to.be.equal 'class'
      expect ht('!.class#id').self-closed .to.be.true

    it 'should parse a "cls.another-class#my-id" as class and id attributes', ->
      expect ht('div.cls.another-class#my-id').tag .to.be.equal 'div'
      expect ht('div.cls.another-class#my-id').attributes.id .to.be.equal 'my-id'
      expect ht('div.cls.another-class#my-id').attributes['class'] .to.be.equal 'cls another-class'

    describe 'formatting', (_) ->

      it 'should parse " div .cls.another-class# my-id " properly', ->
        expect ht(' div .cls.another-class# my-id ').tag .to.be.equal 'div'
        expect ht(' div .cls.another-class# my-id ').attributes.id .to.be.equal 'my-id'
        expect ht(' div .cls.another-class# my-id ').attributes['class'] .to.be.equal 'cls another-class'

      it 'should parse "img tag" as tag properly', ->
        expect ht('img name').tag .to.be.equal 'img name'

  describe 'generator', (_) ->
    
    it 'should generate a div', ->
      expect ht('div').render! .to.be.equal '<div></div>'

    it 'should generate a div with class attribute', ->
      expect ht('.main.text').render! .to.be.equal '<div class="main text"></div>'

    it 'should generate a div with id attribute', ->
      expect ht('#my-id').render! .to.be.equal '<div id="my-id"></div>'

    it 'should generate a div with non-value attribute', ->
      expect ht('div', { id: null }).render! .to.be.equal '<div id></div>'

    it 'should generate a div with style attribute', ->
      expect ht('div', { id: 'main', 'style': { color: 'red' } }).render! 
        .to.be.equal '<div id="main" style="color: red"></div>'

    it 'should generate a div with style attribute list', ->
      expect ht('div', { id: 'main', 'style': { color: 'red', float: 'left' } }).render! 
        .to.be.equal '<div id="main" style="color: red; float: left"></div>'
    
    it 'should generate a div with attributes using an array', ->
      expect ht('div', [ { id: 'main' }, { 'style': { color: 'red', float: 'left' }} ]).render! 
        .to.be.equal '<div id="main" style="color: red; float: left"></div>'

    it 'should generate a div with styles using an array list', ->
      expect ht('div', { 'class': [ 'container', 'main' ] }).render! 
        .to.be.equal '<div class="container main"></div>'

    it 'should create a node and use toString() method', ->
      expect ht('p', 'this is a ' + ht('a', { href: 'http://i.am' }, 'link')).render() 
        .to.be.equal '<p>this is a <a href="http://i.am">link</a></p>'

    it 'should create an img self-closed tag', ->
      expect ht('!img').render() .to.be.equal '<img/>'

    it 'should create a img self-closed tag with attributes', ->
      expect ht('!img', { styles: { width: '100px' } }).render() 
        .to.be.equal '<img styles="width: 100px"/>'

    it 'should ignore child nodes in a self-closed tag', ->
      expect ht('!img', 'some text').render() .to.be.equal '<img/>'

    describe 'doctypes', (_) ->

      it 'should use the default doctype', ->
        expect ht('doctype').render() .to.be.equal '<!DOCTYPE html>'      

      it 'should use the default doctype', ->
        expect ht('doctype mobile').render() .to.be.match /xhtml-mobile12.dtd/    

    describe 'constructors arguments', (_) ->

      it 'should create child nodes with the passed array', ->
        expect ht('ul', [ ht('li', 'one'), ht('li', 'two')]).render!
          .to.be.equal '<ul><li>one</li><li>two</li></ul>'

    describe 'options', (_) ->

      describe 'pretty', (_) ->
        
        it 'should render pretty code with default indent', ->
          expect ht('div', { 'style': { color: 'red' } }, ht('p', 'text')).render { pretty: yes }
            .to.be.equal '<div style="color: red">\n  <p>text</p>\n</div>'

        it 'should render pretty code with nested indentation propertly', ->
          text = ht('div', { 'style': { color: 'red' } }, 
              ht('p', 'hello'), 
              ht('p', ht('span.subtitle', ht('i', 'html')))).render { pretty: yes }

          expect text .to.be.equal '''
          <div style="color: red">
            <p>hello</p>
            <p>
              <span class="subtitle">
                <i>html</i>
              </span>
            </p>
          </div>
          '''

      describe 'indent', (_) ->
        
        it 'should render pretty code with custom indentation', ->
          text = ht('div', { 'style': { color: 'red' } }, 
              ht('p', 'hello'), 
              ht('p', ht('span.subtitle', ht('i', 'html')))).render { pretty: yes, indent: 4 }
          
          expect text .to.be.equal '''
          <div style="color: red">
              <p>hello</p>
              <p>
                  <span class="subtitle">
                      <i>html</i>
                  </span>
              </p>
          </div>
          '''

      describe 'size', (_) ->

        it 'should render pretty code with initial size', ->
          text = ht('div', { 'style': { color: 'red' } }, 
              ht('p', 'hello'), 
              ht('p', ht('span.subtitle', ht('i', 'html')))).render { pretty: yes, size: 2 } .split '\n'
          
          expect text[0] .to.be.equal '    <div style="color: red">'
          expect text[4] .to.be.equal '          <i>html</i>'
          expect text[7] .to.be.equal '    </div>'

      describe 'tabs', (_) ->
        
        it 'should render pretty code with initial size', ->
          text = ht('div', { 'style': { color: 'red' } }, 
              ht('p', 'hello'), 
              ht('p', ht('span.subtitle', ht('i', 'html')))).render { pretty: yes, tabs: true } .split '\n'
          
          expect text[0] .to.be.equal '<div style="color: red">'
          expect text[4] .to.be.equal '\t\t\t<i>html</i>'
          expect text[7] .to.be.equal '</div>'
          