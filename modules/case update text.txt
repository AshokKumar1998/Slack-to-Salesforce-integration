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
        params = req.body.text.split(":"),
        case_number = params[0],
        case_status = params[1];

   force.update( oauthObj,"Case",{
                                        Id: case_number,
                                        origin: "Slack",
                                        status: case_status
                                     })
                                        .then(data => {

                                                let attachments = [];

                                                let fields = [];
                                                fields.push({title: "Case Id", value: case_number, short:false});
                                                fields.push({title: "Status", value: case_status, short:false});
                                                fields.push({title: "Open in Salesforce:", value: oauthObj.instance_url + "/" + case_number, short:false});

                                                let message = {
                                                        text: "Case Status Updated Successfully :",
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
