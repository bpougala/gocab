// this class will associate a user with a taxi driver.

const express = require('express');
const app = express();
const mysql = require('mysql');
const HashMap = require('hashmap');
const sortMap = require('sort-map');
const https = require('https');
const fs = require('fs');
const compare = require('3');
const traverse = require('traverse');

// This Node.JS module serves as an Uber-style driver allocation service whenever the user hires a cab from the app. It takes
// the user's pickup location as coordinates, computes the distance to all available drivers and sorts them before individually
// sending them a ride proposition via Pusher which they can either accept or decline. 

var number_rows = 0;

var array_result = {};

var Pusher = require('pusher');


var pusher = new Pusher({
    appId: '585736',
    key: 'xxx',
    secret: 'yyy',
    cluster: 'eu',
    encrypted: true
});


const distances = new Map();

app.get("/drivers/:id/:latitude/:longitude", (req, res) => {
    const id = req.params.id;
    const latitude = req.params.latitude;
    const longitude = req.params.longitude;

    const connection = mysql.createConnection({
        host: "localhost",
        user: "xxx",
        password: "xxx",
        database: "goCab"
    });

    console.time("getDrivers");
    connection.connect(function (err) {
        if (err) throw err;
        console.time("db-query");
        
        // get all available drivers from SQL database
        const array = connection.query("SELECT driver_id, longitude, latitude FROM drivers", function (err, result, fields) {
            if (err) throw err;
            array_result = result;
            number_rows = result.length;
            var i = 0;

            var unsortedDrivers = new Map();

            const getDrivers = function (data, callback) {
                function next() {
                    const x = data[i++];
                    // edge case
                    if (!x) {
                        return callback(null, unsortedDrivers);
                    } else {
                        const lon = x.longitude;
                        const lat = x.latitude;
                        return getMapQuestDistance(lon, lat, longitude, latitude, function (details) {
                            unsortedDrivers.set(x.driver_id, details);
                            next();
                        });
                    }
                }

                next();


            };


            getDrivers(array_result, (err, data) => {
                console.time("timeToSortDrivers");

                const sortedDrivers = sortMap(unsortedDrivers, ([k1, v1], [k2, v2]) => compare(v1.eta,v2.eta));
                console.timeEnd("getDrivers");
                res.json(mapToJson(sortedDrivers));

                console.timeEnd("timeToSortDrivers");

                // Wait for the drivers map to be sorted before calling
                setTimeout(sendToDrivers, 30, sortedDrivers);


            });


        });

    });

    function sendToDrivers(sortedMap) {

        console.log("Longitude: ", array_result[1].longitude);


        for(const key of sortedMap) {
            // for each key of the map, we create a new booking message including distance from driver to pick-up location,
            // eta and the rating of the user and send it as a message to each individual driver via Pusher Channels.

            console.time("sendBooking");

            const i = parseInt(key[0]);
            var lon = 0.0;
            var lat = 0.0;



            var newBooking = {
                distance: key[1].distance,
                eta: key[1].eta,
                lon: parseFloat(longitude),
                lat: parseFloat(latitude),
                rating: 4
            };
            pusher.trigger("driver-" + key[0],"find-driver",{"message":newBooking});
            console.timeEnd("sendBooking");
        }
    }

});



function getUser(results, id) {
    // really not efficient
    for (var i = 0; i < results.length; i++) {
        console.log("It entered the loop");
            return results[i];
        }
    }
    return 0;
}

function degreesToRadians(degrees) {
    return degrees * Math.PI / 180;
}

function getMapQuestDistance(longitude1, latitude1, longitude2, latitude2, callback) {
    // calls the MapQuest Route API to get duration and distance info
    var body = '';
    https.get(`https://www.mapquestapi.com/directions/v2/route?key=KEY&from=
    ${latitude1},${longitude1}&to=${latitude2},${longitude2}`, (resp) => {
        resp.setEncoding('utf8');
        resp.on('data', (chunk) => {
            body +=  chunk;
        })
        resp.on('end', () => {
            const data = JSON.parse(body);
            //console.log("data: ", chunk.hasTollRoad);
            //console.log("elapsed time: ", data.route.formattedTime);

            const details = {
                eta: data["route"]["time"],
                distance: data["route"]["distance"]
            };
            callback(details);
        });
    });
}
function computeDistance(longitude1, latitude1, longitude2, latitude2) {
    // this function computes Eucledian distance between two points on Earth although I'm not sure whether to use it or not.
    const earthRadiusKm = 6371;

    var dLat = degreesToRadians(latitude2-latitude1);
    var dLon = degreesToRadians(longitude2-longitude1);

    lat1 = degreesToRadians(latitude1);
    lat2 = degreesToRadians(latitude2);

    var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);

    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return earthRadiusKm * c;
}

function mapToJson(map) {
    return JSON.stringify([...map]);
}

// create a secure connection to the server
var privateKey = fs.readFileSync('key.pem').toString();
var certificate = fs.readFileSync('server.crt').toString();


https.createServer({
    key: privateKey,
    cert: certificate,
    //ca: [fs.readFileSync('cr1.crt'), fs.readFileSync('cr2.crt'), fs.readFileSync('cr3.crt')]

}, app).listen(603);
