const REGEX_NUMBER = new RegExp(/^\d+$/)
const REGEX_UNDERSCORE_NUMBER = new RegExp(/^_\d+$/)

export const CREATE_ACTIONS = 'create'
export const REMOVE_ACTIONS = 'remove'
export const CHANGE_ACTIONS = 'change'

/**
 * Generate + configure a function to build actions for nested objects
 * @param  {string} key    key of the attribute containing the array of
 *   nested objects
 * @param  {object} config configuration object that can contain the keys
 *   [CREATE_ACTIONS, REMOVE_ACTIONS, CHANGE_ACTIONS, REORDER_ACTIONS], each of
 *   which is a function. The function should accept the old + new objects and
 *   return an action object.
 * @return {Array}        The generated array of actions
 */
export default function createBuildNestedObjectActions (key, config) {
  return function buildNestedObjectActions (diff, oldObj, newObj) {
    const addActions = []
    const removeActions = []
    const changeActions = []

    if (diff[key]) {
      const nestedObjects = diff[key]
      Object.keys(nestedObjects).forEach((index) => {
        if (config[CREATE_ACTIONS] && isCreateAction(nestedObjects, index))
          addActions.push(
            config[CREATE_ACTIONS](oldObj[key], newObj[key], index)
          )
        else if (config[CHANGE_ACTIONS] && isChangeAction(nestedObjects, index))
          changeActions.push(
            config[CHANGE_ACTIONS](oldObj[key], newObj[key], index)
          )
        else if (
          config[REMOVE_ACTIONS] &&
          isRemoveAction(nestedObjects, index)
        ) {
          const realIndex = index.replace('_', '')
          removeActions.push(
            config[REMOVE_ACTIONS](oldObj[key], newObj[key], realIndex)
          )
        }
      })
    }

    return changeActions.concat(removeActions, addActions)
  }
}

/**
 * Tests a delta to see if it represents a create action.
 * eg. delta: [ [Object] ]
 * @param  {object}  obj [description]
 * @param  {string}  key [description]
 * @return {Boolean}     Returns true if delta reprents a create action,
 *   false otherwise
 */
function isCreateAction (obj, key) {
  return REGEX_NUMBER.test(key) &&
    Array.isArray(obj[key]) &&
    obj[key].length === 1
}

/**
 * Tests a delta to see if it represents a change action.
 * eg. delta: { streetName: [Object] }
 * @param  {object}  obj [description]
 * @param  {string}  key [description]
 * @return {Boolean}     Returns true if delta reprents a change action,
 *   false otherwise
 */
function isChangeAction (obj, key) {
  return REGEX_NUMBER.test(key) &&
    typeof obj[key] === 'object'
}

/**
 * Tests a delta to see if it represents a remove action.
 * eg. delta: [ [Object], 0, 0 ]
 * @param  {object}  obj [description]
 * @param  {string}  key [description]
 * @return {Boolean}     Returns true if delta reprents a remove action,
 *   false otherwise
 */
function isRemoveAction (obj, key) {
  return REGEX_UNDERSCORE_NUMBER.test(key) &&
    Array.isArray(obj[key]) &&
    obj[key].length === 3 &&
    typeof obj[key][0] === 'object' &&
    obj[key][1] === 0 &&
    obj[key][2] === 0
}
