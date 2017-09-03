var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var webpack = require('webpack');

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
    new CopyWebpackPlugin([{ from: __dirname + "/apps/xee/web/static/assets" }]),
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin({
      sourceMap: true,
      compress: {
        warnings: false,
        sequences: true,
        properties:true,
        dead_code: true,
        conditionals: true,
        comparisons: true,
        booleans: true,
        loops: true,
        unused: true,
        if_return: true,
        join_vars: true,
        cascade: true,
        collapse_vars: true,
        reduce_vars: true,
        drop_console: true,
        drop_debugger: true,
      },
      output: {comments: false}
    }),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.AggressiveMergingPlugin()
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
