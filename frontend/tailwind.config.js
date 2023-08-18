const colors = require("tailwindcss/colors");

module.exports = {
  content: ["./src/**/*.js", "./output/**/*.js"],
  theme: {
    extend: {
      transitionProperty: {
        width: "width",
        height: "height",
      },
      colors: {
        primary: colors.lime,
        secondary: colors.stone,
        success: colors.sky,
        danger: colors.amber,
        light: colors.lime[500],
        dark: colors.lime[900],
        divider: colors.gray[400],
        highlight: colors.yellow[100],
      },
    },
  },
  plugins: [],
};
