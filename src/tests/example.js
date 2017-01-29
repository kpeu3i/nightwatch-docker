module.exports = {
    "Example": function (browser) {
        browser
            .windowMaximize()
            .url("https://www.facebook.com/")
            .waitForElementVisible('body', 2000)
            .useCss()
            .click('#pageFooter > div:nth-child(3) > table > tbody > tr:nth-child(1) > td:nth-child(1) > a')
            .pause(1000)
            .assert.containsText('body', 'Sign Up')
            .end();
    }
};
