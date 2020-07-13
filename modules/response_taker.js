"use strict";

let auth = require("./slack-salesforce-auth"),
    force = require("./force");

exports.execute = (req, res) => {


    let slackbody = req.body;

                
                let message = {
                        text: "Found Case :"+slackbody,
                    };
                res.json(message);

           
      
};