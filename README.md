# Disclist
![total-posts-scraped](https://img.shields.io/badge/dynamic/json.svg?label=Total%20Posts%20Scraped&url=https%3A%2F%2Fdisclist-production.herokuapp.com%2Fapi%2Fstats%2Fposts_scraped&query=data&colorB=brightgreen)

![total-searches-tracked](https://img.shields.io/badge/dynamic/json.svg?label=Total%20Searches%20Tracked&url=https%3A%2F%2Fdisclist-production.herokuapp.com%2Fapi%2Fstats%2Fsearches_tracked&query=data&colorB=brightgreen)

![total-channels-active](https://img.shields.io/badge/dynamic/json.svg?label=Total%20Channels%20Active&url=https%3A%2F%2Fdisclist-production.herokuapp.com%2Fapi%2Fstats%2Fchannels_active&query=data&colorB=brightgreen)

Discord Bot to scrape GitHub

[demo invite link](https://discord.gg/nDHADVC)

Too add this bot to your own server click [this link](https://discordapp.com/api/oauth2/authorize?client_id=528335723124883469&permissions=51200&scope=bot)

## Screenshots

<img src="https://raw.githubusercontent.com/ConnorRigby/disclist/master/assets/Screenshot01.png" width=960>

# Usage

## Commands

Here are the basic commands implemeted so far

### Add
Add a url to be scraped
```
@Disclist add https://slo.craigslist.org/search/hhh?query=hot%20dog%20stand&sort=rel
```

### Delete 
Delete a url from being scraped
```
@Disclist delete https://slo.craigslist.org/search/hhh?query=hot%20dog%20stand&sort=rel
```

### List
List all urls being scraped
```
@Disclist list
```

### Ping
Returns all data passed into it
```
@Disclist ping hello world
```

### Checkup
Checks health. (This is a Heroku-ism. Heroku sleeps apps that aren't active)
```
@Disclist checkup
```
