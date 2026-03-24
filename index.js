const express = require('express');
const app = express();
const path = require('path');
const cors = require('cors')

app.use(cors);

app.get("/", (req, res) => {
	res.send("Hello Dev!");
});

app.listen(8080, () => {
	console.log("App launched! Go to http://localhost:8080/ to see");
});
