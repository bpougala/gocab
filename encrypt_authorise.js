const express = require('express');
const app = express();
const mysql = require('mysql');
const request = require('request');
const querystring = require('querystring');
const https = require('https');
const fs = require('fs');

//var credentials = {key: fs.readFileSync('key.pem').toString(), cert: fs.readFileSync('3c894b35c5b682f9.crt').toString()};


app.get("/payment/:card/", (req, res) => {
    const card_encrypted_json = req.params.card;
        //   const street = req.params.street;
        //   const city = req.params.city;
        //   const postcode = req.params.postcode;
        //   const country = req.params.country;

        const apiUrl = 'pal-test.adyen.com';
        const pathUrl = '/pal/servlet/Payment/v30/authorise';
        const user = 'ws@Company.GoCabAccount132';
        const pass = 'u<*JM3&>HB+y6f[f]sAH+>6hf';
        const auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');

        const data = {
            "additionalData": {
                "card.encrypted.json": card_encrypted_json
            },

            "amount": {
                "value": 0,  // zero-value card verification
                "currency": "EUR"
            },
            //      "billingAddress": {
            //         "city": city,
            //         "country": country,
            //         "postalCode": postcode,
            //         "street": street
            //     },
            "reference": generateOrderNumber(),
            "merchantAccount": "GoCabAPP",
            "origin": req.url
        }


        const requestHeaders = {
            'Content-Type': 'application/json',
            'Authorization': auth
        };

        console.log(`Headers: ${JSON.stringify(requestHeaders)}`);

        const options = {
            host: apiUrl,
            path: pathUrl,
            method: 'POST',
            headers: requestHeaders
        };



        process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"; // allow unsafe connections

        var newRequest = https.request(options, (resp) => {
            console.log(`STATUS: ${res.statusCode}`);

            console.log(`HEADERS: ${JSON.stringify(resp.headers)}`);
            resp.setEncoding('utf8');
            resp.on('data', (chunk) => {
                console.log(`BODY: ${chunk}`);
                //res.json(chunk);
                res.send(JSON.stringify(chunk));
            });

            resp.on('end', () => {
                console.log('No more data in response.');
            });
        });

    newRequest.on('error', (e) => {
        console.error(`problem with request: ${e.message}`);
    });

    const dataString = JSON.stringify(data);
    console.log(dataString);

        newRequest.write(dataString);
        newRequest.end();


   // res.end("End of the line, people.");


});


    function generateOrderNumber() {
        // generates an arbitrary 9-figure order number
        let string = "0123456789";
        var randomString = "";
        for (var i = 0; i < 9; i++) {
            randomString += String(Math.floor((Math.random() * 10))); // generate a random number between 1 and 10
        }

        return randomString;
    };

var privateKey = fs.readFileSync('key.pem').toString();
var certificate = fs.readFileSync('server.crt').toString();


https.createServer({
    key: privateKey,
    cert: certificate,
    //ca: [fs.readFileSync('cr1.crt'), fs.readFileSync('cr2.crt'), fs.readFileSync('cr3.crt')]

}, app).listen(808);
