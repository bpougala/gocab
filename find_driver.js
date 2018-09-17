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

var number_rows = 0;

var array_result = {};

var Pusher = require('pusher');


var pusher = new Pusher({
    appId: '585736',
    key: 'df113cf19226ea7d8c4a',
    secret: '211539f9387565944ed9',
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
        user: "sakrtt7d_pougala",
        password: "Tarabiscotta1",
        database: "goCab2"
    });

    console.time("getDrivers");
    connection.connect(function (err) {
        if (err) throw err;
        console.time("db-query");
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


            /*var m = 0;
            const sendToDrivers = function(results, callback) {
                var newBooking = {};
                function iterate() {
                    const y = data[m++];
                    if(!y) {
                        return callback(null, newBooking);
                    } else {

                    }
                }
            }*/


            getDrivers(array_result, (err, data) => {
                console.time("timeToSortDrivers");

                const sortedDrivers = sortMap(unsortedDrivers, ([k1, v1], [k2, v2]) => compare(v1.eta,v2.eta));
                console.timeEnd("getDrivers");
                res.json(mapToJson(sortedDrivers));

                console.timeEnd("timeToSortDrivers");

                // Wait for the drivers map to be sorted before calling
                setTimeout(sendToDrivers, 30, sortedDrivers);


                //});
                /*or(var key in sortedDrivers) {

                    // ask to each driver individually
                    console.time("sendBooking");
                    const i = getUser(result, key);
                    const lon = array_result[i].longitude;
                    const lat = array_result[i].latitude;

                        const newBooking = {
                            distance: sortedDrivers.get(key).distance,
                            time_to_origin: sortedDrivers.get(key).time,
                            rating:4
                        };
                        console.log("newBooking: ", newBooking);
                        pusher.trigger('drivers','new-user', {message:newBooking});
                        console.timeEnd("sendBooking");
                    };*/


            });


        });

    });

    function sendToDrivers(sortedMap) {

        console.log("Longitude: ", array_result[1].longitude);


        for(const key of sortedMap) {
            // for each key of the map, we create a new booking message including distance from driver to pick-up location,
            // eta and the rating of the user and sent it as a message to each individual driver via Pusher Channels.

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
        if (results[i].driver_id === id) {
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
    https.get(`https://www.mapquestapi.com/directions/v2/route?key=VJtpFCP5ZOpMAymke0ZKRGGliMUonPd4&from=
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

var privateKey = fs.readFileSync('key.pem').toString();
var certificate = fs.readFileSync('server.crt').toString();


https.createServer({
    key: privateKey,
    cert: certificate,
    //ca: [fs.readFileSync('cr1.crt'), fs.readFileSync('cr2.crt'), fs.readFileSync('cr3.crt')]

}, app).listen(603);