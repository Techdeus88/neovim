---
id: 03_one_step_back_two_forward
aliases: []
tags: []
---

#:q
:q
n:qa
:q
"::::::::q:q"## One step back, two forward

Change this text:

```javascript
var foo = "method("+argument1+","+argument2+")";
```

to this:

```javascript
var foo = "method(" + argument1 + "," + argument2 + ")";
```

Steps:

1. find "+" with `f+`
2. delete and switch to insert mode with `s`
3. Type ` + `
4. Leave insert mode
5. find the next "+" with `;`
6. Repeat with `.`
