!function(e){if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.htgen=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(_dereq_,module,exports){
var htgen, Node, Generator, parse, extend, toString, isString, isObject, isArray, exports, slice$ = [].slice;
htgen = function(){
  var instance;
  instance = Object.create(Node.prototype);
  Node.apply(instance, arguments);
  return instance;
};
Node = (function(){
  Node.displayName = 'Node';
  var prototype = Node.prototype, constructor = Node;
  function Node(tag){
    var child, ref$, tagName, attributes, this$ = this;
    child = slice$.call(arguments, 1);
    this.tag = 'div';
    this.attributes = {};
    this.childNodes = [];
    if (tag instanceof Node) {
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
    if (isArray(
    child)) {
      child.forEach(function(it){
        if (it instanceof Node) {
          return this$.child(
          it);
        } else if (isString(
        it)) {
          return this$.childNodes.push(
          it);
        } else if (isObject(
        it)) {
          return this$.attr(
          it);
        }
      });
    }
  }
  prototype.child = function(it){
    if (it instanceof Node) {
      this.push(
      it);
    } else if (isString(
    it)) {
      this.push(
      htgen.apply(this, arguments));
    }
    return this;
  };
  prototype.c = function(){
    return this.child.apply(this, arguments);
  };
  prototype.push = function(it){
    if (it instanceof Node) {
      it.parent = this;
      this.childNodes.push(
      it);
    }
    return this;
  };
  prototype.cchild = function(){
    this.child.apply(this, arguments);
    return this.childNodes.slice(-1);
  };
  prototype.cc = function(){
    return this.cchild.apply(this, arguments);
  };
  prototype.attr = function(name, value){
    if (isObject(
    name)) {
      extend(this.attributes, name);
    } else if (isString(
    name)) {
      this.attributes[name] = value;
    }
    return this;
  };
  prototype.a = function(){
    return this.attrs.apply(this, arguments);
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
  prototype.render = function(options){
    return new Generator(this, options).text();
  };
  prototype.r = function(){
    return this.render.apply(this, arguments);
  };
  prototype.text = function(){
    return this.render.apply(this, arguments);
  };
  prototype.toString = function(){
    return this.text.apply(this, arguments);
  };
  return Node;
}());
Generator = (function(){
  Generator.displayName = 'Generator';
  var EOL, TAB, tagOpenRegex, tagCloseRegex, prototype = Generator.prototype, constructor = Generator;
  EOL = '\n';
  TAB = '\t';
  tagOpenRegex = /^(<[^>]+>)([\s|\t]+)?</;
  tagCloseRegex = />([\s|\t]+)?(<\/[^<]+>$)/;
  prototype.options = {
    pretty: false,
    size: 0,
    indent: 2,
    tabs: false
  };
  function Generator(node, options){
    if (!(node instanceof Node)) {
      throw new TypeError('First argument must be an instance of Node');
    }
    this.node = node;
    extend(this.options, options);
  }
  prototype.renderAttrs = function(){
    var buf, name, ref$, value, tmp, styles, id, prop, own$ = {}.hasOwnProperty;
    buf = [];
    for (name in ref$ = this.node.attributes) if (own$.call(ref$, name)) {
      value = ref$[name];
      if (name) {
        tmp = " " + name;
        if (isObject(
        value)) {
          styles = [];
          for (id in value) if (own$.call(value, id)) {
            prop = value[id];
            styles.push(
            id + ": " + prop);
          }
          value = styles.join('; ');
        }
        if (value) {
          tmp += "=\"" + value + "\"";
        }
        buf.push(
        tmp);
      }
    }
    return buf.join('');
  };
  prototype.renderBody = function(){
    var buf, this$ = this;
    buf = [];
    this.node.childNodes.forEach(function(it){
      if (isString(
      it)) {
        return buf.push(
        it);
      } else if (it instanceof Node) {
        return buf.push(
        it.render(this$.options));
      }
    });
    return buf;
  };
  prototype.indent = function(){
    var value;
    if (!this.options.tabs) {
      value = Array(this.options.indent + 1).join(' ');
    } else {
      value = TAB;
    }
    return value;
  };
  prototype.applyIndent = function(body){
    var indent, this$ = this;
    body == null && (body = []);
    if (body) {
      indent = this.indent();
      body.forEach(function(str, line){
        var indent;
        indent = Array(line === 0
          ? line + 2
          : line + 1).join(this$.indent());
        return body[line] = indent + "" + str;
      });
      body = body.join(EOL);
    }
    return body;
  };
  prototype.render = function(){
    var body, text;
    body = this.renderBody();
    if (this.options.pretty && !this.node.parent) {
      body = this.applyIndent(
      body);
    } else {
      body = body.join('');
    }
    text = "<" + this.node.tag + this.renderAttrs() + ">" + body + "</" + this.node.tag + ">";
    if (this.options.pretty && body) {
      text = text.replace(tagOpenRegex, "$1" + EOL + "$2<");
      if (!this.node.parent) {
        text = text.replace(tagCloseRegex, ">" + EOL + "$2");
      }
    }
    return text;
  };
  prototype.text = function(){
    return this.render.apply(this, arguments);
  };
  prototype.toString = function(){
    return this.render.apply(this, arguments);
  };
  return Generator;
}());
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
extend = function(target, origin){
  var name, value, own$ = {}.hasOwnProperty;
  target == null && (target = {});
  for (name in origin) if (own$.call(origin, name)) {
    value = origin[name];
    if (value) {
      target[name] = value;
    }
  }
  return target;
};
toString = Object.prototype.toString;
isString = function(it){
  return typeof it === 'string';
};
isObject = function(it){
  return toString.call(
  it) === '[object Object]';
};
isArray = function(it){
  return toString.call(
  it) === '[object Array]';
};
exports = module.exports = htgen;
exports.Node = Node;
exports.Generator = Generator;
},{}]},{},[1])
(1)
});