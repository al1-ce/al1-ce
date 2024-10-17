const fs = require("fs");
const express = require("express");
const app = express();

function random_float(min, max) {
    return Math.random() * (max - min) + min;
}

function random_int(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function get_file_list(dir) {
    let files = []
    fs.readdirSync(dir).forEach(file => {
        files.push(file);
    });
    return files;
}

function get_random_image_name(dir) {
    let path = __dirname + `/images/${dir}`;
    let files = get_file_list(path);
    const length = files.length;
    let img_idx = random_int(0, length - 1);
    return path + "/" + files[img_idx];
}

function get_image_data(path) {
    return fs.readFileSync(path);
}

app.get("/", (req, res) => {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end("Some random API stuff.\n");
});

let img_dirs = get_file_list(__dirname + "/images");
for (let dir of img_dirs) {
    app.get(`/api/images/${dir}`, (req, res) => {
        let img = get_random_image_name(dir);
        let img_data = get_image_data(img);
        if (img.endsWith(".jpg") || img.endsWith(".jpeg")) {
            res.writeHead(200, { "Content-Type": "image/jpeg" });
            res.end(img_data, "binary");
        } else
        if (img.endsWith(".png")) {
            res.writeHead(200, { "Content-Type": "image/png" });
            res.end(img_data, "binary");
        } else
        if (img.endsWith(".gif")) {
            res.writeHead(200, { "Content-Type": "image/gif" });
            res.end(img_data, "binary");
        } else {
            res.writeHead(200, { "Content-Type": "text/plain" });
            res.end("Unknown format.\n");
        }
    });
}

const port = process.env.PORT || 3000;

app.listen(port, () => console.log(`Server running on ${port}, http://localhost:${port}`));

module.exports = app;

