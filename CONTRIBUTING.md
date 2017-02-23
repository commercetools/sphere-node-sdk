# Contributing to sphere-node-sdk

Please take a moment to review this document in order to make the contribution
process easy and effective for everyone involved.

Following these guidelines helps to communicate that you respect the time of
the developers managing and developing this open source project. In return,
they should reciprocate that respect in addressing your issue or assessing
patches and features.

## Setting Up a Local Copy
1. Clone the repo with `git clone git@github.com:sphere-node-sdk.git`
2. Run `npm install`
3. Setup the credentials by running 
    ```bash
    $ ./create_config.sh
    ```
    Make sure you have _SPHERE_PROJECT_KEY_, _SPHERE_CLIENT_ID_, _SPHERE_CLIENT_SECRET_ in your environment variables before running. You can see the credentials generated in `config.js`
4. To run all packages tests simply do `grunt test` (we use [jasmine-node](https://github.com/mhevery/jasmine-node)).
5. Linting and static checks are done by `grunt lint`.
6. You can check the code coverage by running `grunt coverage`


## Styleguide
Regarding code style like indentation and whitespace, **follow the conventions you see used in the source already**. Please have a look at this [referenced coffeescript](https://github.com/polarmobile/coffeescript-style-guide) styleguide when doing changes to the code.
We also have a coffee linter.
You can lint your code by running `grunt lint`

## Commit message
Make sure your commit messages follow [Angular's commit message format](https://github.com/angular/angular.js/blob/master/CONTRIBUTING.md#-git-commit-guidelines). To make this easy run `npm run commit` from the root.

````
    docs(contributing): add example of a full commit message

    The example commit message in the contributing.md document is not a concrete example. This is a problem because the
    contributor is left to imagine what the commit message should look like based on a description rather than an example. Fix the
    problem by making the example concrete and imperative.

    Closes #1
    BREAKING CHANGE: imagination no longer works
````

## Branching
When creating a branch. Use the issue number(without the '#') as the prefix and add a short title, like: `1-commit-message-example`

## Labels
We have two categories of labels, one for _status_ and _type_ of issue.
Please add the relevant label as needed. When you working on an issue, please add the _status: in progress_ label and when you want it to be reviewed. Add the _status: in review_ and it will be reviewed.

## Tests
Before submitting a PR, please make sure you code is well unit tests, and build passes on CI
We use [jasmine-node](https://github.com/mhevery/jasmine-node) for testing.

## Submitting a Pull Request
Good pull requests, such as patches, improvements, and new features, are a fantastic help. They should remain focused in scope and avoid containing unrelated commits.

Please **ask first** if somebody else is already working on this or the core developers think your feature is in-scope for the related package / project. Generally always have a related issue with discussions for whatever you are including.

Please also provide a **test plan**, i.e. specify how you verified that your addition works.

Please adhere to the coding conventions used throughout a project (indentation,
accurate comments, etc.) and any other requirements (such as test coverage).

## Assignees and reviewees
After submitting a PR, assign yourself the PR and add part of the NodeJS team in the reviewers section.

## Releases
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```
