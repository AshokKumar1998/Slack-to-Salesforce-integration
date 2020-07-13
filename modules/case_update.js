"use strict";

let auth = require("./slack-salesforce-auth"),
    force = require("./force"),
    CASEUPDATE_TOKEN = process.env.SLACK_CASEUPDATE_TOKEN;

exports.execute = (req, res) => {

    if (req.body.token != CASEUPDATE_TOKEN) {
        res.send("Invalid token");
        return;
    }

    let slackUserId = req.body.user_id,
        oauthObj = auth.getOAuthObject(slackUserId),
        params = req.body.text;
        

   force.update( oauthObj,"Case",{
                                        Id: params,
                                        origin: "Slack"
                                     })
                                        .then(data => {

                                                let attachments = [];

                                                let fields = [];
                                                fields.push({title: "Open in Salesforce:", value: oauthObj.instance_url + "/" + params, short:false});

                                                let message = {
                                                        text: "Getting Options For : ",
                                                        attachments: [
                                                            {color: "#F2CF5B", fields: fields}
                                                        ]
                                                    };
                                                res.json(message);



                                        }).catch(error => {
                                            if (error.code == 401) {
                                                res.send(`Visit this URL to login to Salesforce: https://${req.hostname}/login/` + slackUserId);
                                            } else {
                                                res.send("An error as occurred "+error);
                                            }
                                        });
        
};
