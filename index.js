const fs = require("fs");
const http = require("http");
const url = require("url");
const express = require("express")
const app = express();
/**
 * Returns a random number between min (inclusive) and max (exclusive)
 */
function random_float(min, max) {
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min (inclusive) and max (inclusive).
 * The value is no lower than min (or the next integer greater than min
 * if min isn't an integer) and no greater than max (or the next integer
 * lower than max if max isn't an integer).
 * Using Math.round() will give you a non-uniform distribution!
 */
function random_int(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function get_random_image(dir) {
    const length = fs.readdirSync(__dirname + `/images/${dir}`).length;
    let img_idx = random_int(0, length - 1);
    return fs.readFileSync(__dirname + `/images/greentext/${img_idx}.png`);
}

// app.use(express.static(__dirname + "../public"));
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.writeHead(200, { "Content-Type": 'text/plain' });
    res.end("Some random API stuff.\n");

});

app.get('/api/greentext', (req, res) => {
    let img = get_random_image("greentext");
    res.writeHead(200, { "Content-Type": 'image/png' });
    res.end(img, "binary");

});

const port = process.env.PORT || 3000;

app.listen(port, () => console.log(`Server running on ${port}, http://localhost:${port}`));

module.exports = app;
