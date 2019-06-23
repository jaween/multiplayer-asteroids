var path = require('path');

module.exports = {
  entry: './build/main.js',
  output: {
    path: path.join(__dirname, 'build'),
    publicPath: path.join(__dirname, 'build/'),
    filename: 'main.bundle.js',
  },
}
