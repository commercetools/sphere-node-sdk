# Contributing

## Styleguide
We <3 CoffeeScript! So please have a look at this [referenced coffeescript](https://github.com/polarmobile/coffeescript-style-guide) styleguide when doing changes to the code.
Regarding code style like indentation and whitespace, **follow the conventions you see used in the source already**.

## Submitting pull requests
1. Follow code styleguides
2. Include thoughtfully-worded, well-structured [Jasmine](http://jasmine.github.io/) specs
3. Update the documentation to reflect any changes
4. Push to your fork and submit a pull request

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```