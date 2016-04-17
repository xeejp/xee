var ExtractTextPlugin = require("extract-text-webpack-plugin"); 
var CopyWebpackPlugin = require("copy-webpack-plugin");
module.exports = {
    entry: ["./web/static/js/app.js", "./web/static/css/app.css"],
    output: {
        path: "./priv/static",
        filename: "js/app.js"
    },
    module: {
        loaders: [{
            test: /\.js$/,
            exclude: /node_modules/,
            loader: "babel",
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
        new CopyWebpackPlugin([{ from: "./web/static/assets" }])
    ],
    resolve: {
        extensions: [
            "", ".js"
        ],
        modulesDirectories: [
            "node_modules",
            __dirname + "/web/static/js"
        ]
    }
};
