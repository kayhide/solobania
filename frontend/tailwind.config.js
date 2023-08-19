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
        primary: colors.indigo,
        secondary: colors.stone,
        success: colors.sky,
        danger: colors.amber,
        divider: colors.stone,
        highlight: colors.yellow[100],
      },
    },
  },
  plugins: [],
};
