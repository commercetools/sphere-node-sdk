# Contributing

## Setting Up a Local Copy
1. Clone the repo with git clone git@github.com:sphereio/sphere-node-sdk.git
2. Run `npm install` in the root nodejs folder. This will ensure that all package dependencies are properly installed / linked.
3. Run `create_config.sh` and provide your SPHERE.IO and IRON.IO MQ credentials as environmental variables
4. To run all packages tests run `grunt test`    

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
