const fs = require("fs");
const filename = `${__dirname}/lib/porque.parser.js`;
const filecontents = fs.readFileSync(filename).toString();
const filecontentsfixed = filecontents.replace(/root."([^\"]+)"/g, "window[\"$1\"]");
fs.writeFileSync(filename, filecontentsfixed, "utf8");