Example repo around the template engine TDD excercise.

## Features:

### Replace values

```ruby
Templater.new("Hello, {{who}}!", who: 'world').render
# => "Hello, world!"
```

### Show/hide sections

```ruby
template = "You are logged in{{#admin}} and administrator{{/admin}}."
Templater.new(template, admin: true)
# => "You are logged in and administrator."
Templater.new(template, admin: false)
# => "You are logged."
```

### Iterate over values

```ruby
template = "Names: {{#names}}{{name}} {{/names}}"
data = { names: [{ name: 'John' }, { name: 'Graham' }] }
Templates.new(template, data).render
# => "Names: John Graham "
```

### Use objects instead of hashes

```ruby
require 'ostruct'
Templater.new("Hello, {{who}}!", OpenStruct.new(who: 'world')).render
# => "Hello, world!"
```
