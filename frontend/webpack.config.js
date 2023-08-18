const HtmlPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const path = require("path");

const isDevServer = process.argv.some(
  (a) => path.basename(a) === "webpack-dev-server"
);

module.exports = {
  entry: {
    main: "./src/index.js",
  },
  output: {
    filename: `js/[name]${isDevServer ? "" : "-[hash:8]"}.js`,
    chunkFilename: `js/[name]${isDevServer ? "" : "-[hash:8]"}.chunk.js`,
    assetModuleFilename: "media/[name]-[hash:8][ext]",
    path: path.resolve(__dirname, "dist"),
  },

  resolve: {
    alias: {
      images: path.resolve(__dirname, "src/assets/images/"),
    },
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: `css/[name]${isDevServer ? "" : "-[contenthash:8]"}.css`,
      chunkFilename: `css/[name]${
        isDevServer ? "" : "-[contenthash:8]"
      }.chunk.css`,
      ignoreOrder: false,
    }),
    new HtmlPlugin({
      filename: "index.html",
      template: `./src/index.html`,
      // favicon: './src/assets/favicon/favicon.ico',
      meta: {
        BASE_URL: process.env.BASE_URL,
      },
      chunks: ["main"],
    }),
  ],

  module: {
    rules: [
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          { loader: MiniCssExtractPlugin.loader },
          { loader: "css-loader" },
          { loader: "postcss-loader" },
        ],
      },
      {
        test: /\.(png|jpg|jpeg|gif|tiff|eot|otf|ttf|woff|woff2)$/,
        type: "asset/resource",
      },
      {
        test: /\.(ico|svg)$/,
        type: "asset",
        parser: {
          dataUrlCondition: {
            limit: 4096,
          },
        },
      },
    ],
  },

  devServer: {
    host: "0.0.0.0",
    port: "8080",
    hot: true,
    headers: {
      "Access-Control-Allow-Origin": "*",
    },
    proxy: {
      "/api": "http://rails:3000",
      "/rails": "http://rails:3000",
    },
    client: {
      webSocketURL: `ws://${process.env.FRONTEND_HOST}/ws`
    },
  },
};
