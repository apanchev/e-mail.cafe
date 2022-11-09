/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./views/*.ejs"],
  theme: {
    extend: {
      colors: {
        primary: {
          100: "#f5a43f",
          200: "#f5a43f",
          300: "#f5a43f",
          400: "#f5a43f",
          500: "#f5a43f",
          600: "#f5a43f",
          700: "#f5a43f",
          800: "#f5a43f",
          900: "#f5a43f",
        },
        secondary: {
          100: "#dc736f",
          200: "#dc736f",
          300: "#dc736f",
          400: "#dc736f",
          500: "#dc736f",
          600: "#dc736f",
          700: "#dc736f",
          800: "#dc736f",
          900: "#dc736f",
        },
      },
    },
  },
  plugins: [require("@tailwindcss/forms"), require("@tailwindcss/line-clamp")],
};
