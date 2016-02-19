# Contributing

## Committing
In order to keep commit messages consistent and to be able to generate changelogs automatically we use `commitizen` with `cz-conventional-changelog`. You can read more about it [here](https://commitizen.github.io/cz-cli/). We encourage you to watch this [video tutorial](https://egghead.io/lessons/javascript-how-to-write-a-javascript-library-committing-a-new-feature-with-commitizen) on how to commit a new feature with commitizen.  
So like shown in the video above, to commit changes you simply enter `npm run commit` and follow the guide.

## Styleguide
We <3 CoffeeScript! So please have a look at this [referenced coffeescript](https://github.com/polarmobile/coffeescript-style-guide) styleguide when doing changes to the code.
Regarding code style like indentation and whitespace, **follow the conventions you see used in the source already**.

## Submitting pull requests
1. Follow code styleguides
2. Include thoughtfully-worded, well-structured [Jasmine](http://jasmine.github.io/) specs
3. Update the documentation to reflect any changes
4. Push to your fork and submit a pull request
5. commit messages are conventional-changelog conform

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```
