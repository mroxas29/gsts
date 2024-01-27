const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = 8080;

// Serve static files from the "assets" directory
app.use(express.static(path.join(__dirname, "assets")));

app.use(express.static("public"));

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}/`);
});
