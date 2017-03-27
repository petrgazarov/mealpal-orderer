## Mealpal Orderer

### Orders mealpal lunch for you (because you forgot again)

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

### [LIVE SITE (demo only - not for use)](https://mealpal-orderer.herokuapp.com/)

### Email Integration (Sendgrid)
The app has [Sendgrid](https://app.sendgrid.com/) integration and can send "Thank you" emails to users who sign up.

To configure emails:

- Sign up for a free Sendgrid account
- set these variables in your app:

```
SENDGRID_API_KEY
SENDGRID_DOMAIN
SENDGRID_PASSWORD
SENDGRID_USERNAME
```

- (optional) set these variables to receive status reports for your users:

```
ADMIN_EMAIL_REPORTS=true
ADMIN_EMAIL=<your_email_address>
```

Doing the last step will send both error and success reports for all of the orders that are being attempted by the app.

### Gotchas:
- Depending on your timezone, you may have to configure [run_orderer.rb](app/commands/run_orderer.rb) differently (right now has time triggers which make sense for New York timezone)
- clockwork won't work if the app is "asleep" at the time of the trigger. A short-term solution is to add [heroku scheduler](https://elements.heroku.com/addons/scheduler) addon and just curl your dyno url every 10 minutes. However, you will soon run out of free dyno hours if you are not paying heroku. A PR with a more robust (free) solution is welcome!
