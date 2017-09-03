var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
module.exports = {
  entry: [__dirname + "/apps/xee/web/static/js/app.js", __dirname + "/apps/xee/web/static/css/app.css", __dirname + "/apps/xee/web/static/js/footerFixed.js"],
  output: {
    path: __dirname + "/apps/xee/priv/static",
    filename: "js/app.js"
  },
  module: {
    loaders: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: "babel-loader",
      query: {
        presets: ["es2015"]
      }
    }, {
      test: /\.css$/,
      loader: ExtractTextPlugin.extract("css")
    }]
  },
  plugins: [
    new ExtractTextPlugin("css/app.css"),
    new CopyWebpackPlugin([{ from: __dirname + "/apps/xee/web/static/assets" }])
  ],
  resolve: {
    extensions: [
      "", __dirname + "/js"
    ],
    modulesDirectories: [
      "node_modules",
      __dirname + "/apps/xee/web/static/js",
    ]
  }
};
