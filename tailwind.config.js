const cloneDeep = require("clone-deep")
const bloomTheme = cloneDeep(require("@bloom-housing/ui-components/tailwind.config.js"))

// Modify bloomTheme to override any Tailwind vars
// For example:
// bloomTheme.theme.colors.white = "#f0f0e9"

// tailwind will automatically purge unused styles when `NODE_ENV` is set to `production`
// bloomTheme.purge = [
//   __dirname + '/app/javascript/**/*.tsx'
// ]

module.exports = bloomTheme
