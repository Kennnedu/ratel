const path = require('path');
const { VueLoaderPlugin } = require('vue-loader')

module.exports = {
  entry: './javascripts/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'public/js/')
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      }
    ]
  },
  plugins: [
    new VueLoaderPlugin()
  ]
};
