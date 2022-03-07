const { webpackConfig, merge } = require('shakapacker')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const vueConfig = require('./loaders/vue');

module.exports = merge(vueConfig, webpackConfig)
