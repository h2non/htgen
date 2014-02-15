!function(e){if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.htgen=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(_dereq_,module,exports){
var ref$, extend, clone, isString, isObject, isArray, exports, Generator;
ref$ = _dereq_('./helpers'), extend = ref$.extend, clone = ref$.clone, isString = ref$.isString, isObject = ref$.isObject, isArray = ref$.isArray;
exports = module.exports = Generator = (function(){
  Generator.displayName = 'Generator';
  var EOL, TAB, tagOpenRegex, tagCloseRegex, prototype = Generator.prototype, constructor = Generator;
  EOL = '\n';
  TAB = '\t';
  tagOpenRegex = /^(<[^>]+>)([\s|\t]+)?</;
  tagCloseRegex = />([\s|\t]+)?(<\/[^<]+>$)/;
  prototype.defaults = {
    pretty: false,
    size: 0,
    indent: 2,
    tabs: false
  };
  function Generator(node, options){
    if (!isObject(
    node)) {
      throw new TypeError('First argument must be an instance of Node');
    }
    this.node = node;
    if (options === true) {
      options = {
        pretty: true
      };
    }
    this.options = extend(clone(
    this.defaults), options);
  }
  prototype.indent = function(){
    if (this.options.tabs) {
      return Array(this.options.size + 1).join(TAB);
    } else {
      return Array(this.options.size * this.options.indent + 1).join(' ');
    }
  };
  prototype.childIndent = function(it){
    if (/^</.test(
    this.options.pretty && it)) {
      return this.indent() + "" + it + EOL;
    } else {
      return it;
    }
  };
  prototype.renderAttrs = function(){
    var buf, name, ref$, value, attr, own$ = {}.hasOwnProperty;
    buf = [];
    for (name in ref$ = this.node.attributes) if (own$.call(ref$, name)) {
      value = ref$[name];
      if (name) {
        attr = " " + name;
        if (isObject(
        value)) {
          value = this.renderStyles(
          value);
        } else if (isArray(
        value)) {
          value = value.join(' ');
        }
        if (value) {
          attr += "=\"" + value + "\"";
        }
        buf.push(
        attr);
      }
    }
    return buf.join('');
  };
  prototype.renderStyles = function(it){
    var buf, id, prop, own$ = {}.hasOwnProperty;
    buf = [];
    for (id in it) if (own$.call(it, id)) {
      prop = it[id];
      buf.push(
      id + ": " + prop);
    }
    return buf.join('; ');
  };
  prototype.renderChild = function(){
    var body, this$ = this;
    body = [];
    this.node.childNodes.forEach(function(it){
      if (isString(
      it)) {
        return body.push(
        it);
      } else if (isObject(
      it)) {
        return body.push(
        this$.renderChildNode(
        it));
      }
    });
    return body.join('');
  };
  prototype.renderChildNode = function(it){
    return this.childIndent(
    it.render(
    extend(clone(
    this.options), {
      size: this.options.size + 1
    })));
  };
  prototype.nodeIndent = function(it){
    var indent;
    if (this.options.pretty) {
      indent = this.options.size > 0 ? this.indent() : '';
      it = indent + it.replace(tagOpenRegex, "$1" + EOL + "$2<").replace(tagCloseRegex, ">" + EOL + indent + "$2");
      if (this.node.hasParent()) {
        it += EOL;
      }
    }
    return it;
  };
  prototype.render = function(){
    return this.nodeIndent(
    "<" + this.node.tag + this.renderAttrs() + ">" + this.renderChild() + "</" + this.node.tag + ">");
  };
  prototype.toString = function(){
    return this.render.apply(this, arguments);
  };
  return Generator;
}());
},{"./helpers":2}],2:[function(_dereq_,module,exports){
var toString, clone, isString, isObject, isArray;
toString = Object.prototype.toString;
exports.extend = function(target, origin){
  var name, value, own$ = {}.hasOwnProperty;
  target == null && (target = {});
  for (name in origin) if (own$.call(origin, name)) {
    value = origin[name];
    target[name] = value;
  }
  return target;
};
exports.clone = clone = function(it){
  var target, name, value, own$ = {}.hasOwnProperty;
  target = {};
  for (name in it) if (own$.call(it, name)) {
    value = it[name];
    if (isArray(
    value) && name !== 'childNodes') {
      value = value.slice();
    } else if (isObject(
    value)) {
      value = clone(
      value);
    }
    target[name] = value;
  }
  return target;
};
exports.isString = isString = function(it){
  return typeof it === 'string';
};
exports.isObject = isObject = function(it){
  return toString.call(
  it) === '[object Object]';
};
exports.isArray = isArray = function(it){
  return toString.call(
  it) === '[object Array]';
};
},{}],3:[function(_dereq_,module,exports){
var Generator, Node, exports;
Generator = _dereq_('./generator');
Node = _dereq_('./node');
exports = module.exports = Node.create;
exports.Node = Node;
exports.Generator = Generator;
},{"./generator":1,"./node":4}],4:[function(_dereq_,module,exports){
var ref$, extend, isString, isObject, isArray, Generator, exports, Node, isNode, parse, slice$ = [].slice;
ref$ = _dereq_('./helpers'), extend = ref$.extend, isString = ref$.isString, isObject = ref$.isObject, isArray = ref$.isArray;
Generator = _dereq_('./generator');
exports = module.exports = Node = (function(){
  Node.displayName = 'Node';
  var prototype = Node.prototype, constructor = Node;
  Node.create = function(){
    var instance;
    instance = Object.create(
    Node.prototype);
    Node.apply(instance, arguments);
    return instance;
  };
  function Node(){
    this.tag = 'div';
    this.attributes = {};
    this.childNodes = [];
    this.applyArgs.apply(this, arguments);
  }
  prototype.applyArgs = function(tag){
    var child, ref$, tagName, attributes, this$ = this;
    child = slice$.call(arguments, 1);
    if (isNode(
    tag)) {
      this.child(
      tag);
    } else if (isObject(
    tag)) {
      this.child(
      tag);
    } else if (isString(
    tag)) {
      ref$ = parse(
      tag), tagName = ref$.tagName, attributes = ref$.attributes;
      if (tagName) {
        this.tag = tagName;
      }
      if (attributes) {
        this.concatAttr('class', attributes['class']);
        if (attributes.id) {
          this.attributes.id = attributes.id;
        }
      }
    }
    return child.forEach(function(it){
      if (isNode(
      it)) {
        return this$.push(
        it);
      } else if (isString(
      it)) {
        return this$.push(
        it);
      } else if (isObject(
      it) || isArray(
      it)) {
        return this$.attr(
        it);
      }
    });
  };
  prototype.push = function(it){
    if (isString(
    it)) {
      this.childNodes.push(
      it);
    } else if (isNode(
    it)) {
      it.parent = this;
      this.childNodes.push(
      it);
    }
    return this;
  };
  prototype.child = function(it){
    if (isNode(
    it)) {
      this.push(
      it);
    } else if (isString(
    it)) {
      this.push(
      Node.create.apply(this, arguments));
    }
    return this;
  };
  prototype.c = function(){
    return this.child.apply(this, arguments);
  };
  prototype.cchild = function(){
    this.child.apply(this, arguments);
    return this.childNodes.slice(-1);
  };
  prototype.cc = function(){
    return this.cchild.apply(this, arguments);
  };
  prototype.attr = function(name, value){
    var this$ = this;
    if (isObject(
    name)) {
      extend(this.attributes, name);
    } else if (isArray(
    name)) {
      name.forEach(function(it){
        var ref$;
        if (isObject(
        it)) {
          this$.attr(
          it);
        }
        if (isString(
        it)) {
          return ref$ = this$.attributes, ref$[it] = null, ref$;
        }
      });
    } else if (isString(
    name)) {
      this.attributes[name] = value;
    }
    return this;
  };
  prototype.a = function(){
    return this.attr.apply(this, arguments);
  };
  prototype.concatAttr = function(name, value){
    if (name && value) {
      if (this.attributes.hasOwnProperty(
      name)) {
        this.attributes['class'] += ' ' + attributes['class'];
      } else {
        this.attr.apply(this, arguments);
      }
    }
    return this;
  };
  prototype.hasParent = function(){
    return this.hasOwnProperty(
    'parent');
  };
  prototype.render = function(options){
    return new Generator(this, options).render();
  };
  prototype.r = function(){
    return this.render.apply(this, arguments);
  };
  prototype.toString = function(){
    return this.render.apply(this, arguments);
  };
  return Node;
}());
isNode = function(it){
  return it instanceof Node;
};
parse = function(it){
  var result, ref$, head, id, tagName, classes, attrs;
  result = {};
  ref$ = it.trim().split('#'), head = ref$[0], id = ref$[1];
  ref$ = head.split('.'), tagName = ref$[0], classes = slice$.call(ref$, 1);
  if (tagName) {
    result.tagName = tagName.trim();
  }
  if (id || classes) {
    attrs = result.attributes = {};
    if (id) {
      attrs.id = id.trim();
    }
    if (classes) {
      attrs['class'] = classes.join(' ').trim();
    }
  }
  return result;
};
},{"./generator":1,"./helpers":2}]},{},[3])
(3)
});