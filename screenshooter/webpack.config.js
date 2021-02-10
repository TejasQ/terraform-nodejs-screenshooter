const path = require("path");

module.exports = {
  mode: "production",
  context: __dirname,
  entry: ["./index.ts"],
  externals: [require("webpack-node-externals")()],
  output: {
    path: path.join(__dirname, "out"),
    filename: "index.js",
    library: "index",
    libraryTarget: "umd",
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: /(node_modules|bower_components)/,
        use: ["ts-loader"],
      },
    ],
  },
  resolve: {
    extensions: [".ts", ".js"],
  },
  target: "node",
};
