# Disclist

Discord Bot to scrape GitHub

[demo invite link](https://discord.gg/nDHADVC)

# Usage

## Commands

Here are the basic commands implemeted so far

### Add
Add a url to be scraped
```
@Disclist add https://slo.craigslist.org/search/hhh?query=hot%20dog%20stand&sort=rel
```

### Remove 
Remove a url from being scraped
```
@Disclist remove https://slo.craigslist.org/search/hhh?query=hot%20dog%20stand&sort=rel
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