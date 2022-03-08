const { VueLoaderPlugin } = require('vue-loader');
// test: /\.vue(\.erb)?$/,
module.exports = {
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      }
    ]
  },
  plugins: [new VueLoaderPlugin()],
  resolve: {
    extensions: ['.vue', '.css', '.scss']
  }
}
