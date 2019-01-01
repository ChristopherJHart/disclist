alias Disclist
alias Disclist.Craigslist
alias Disclist.Craigslist.Query
alias Disclist.Craigslist.QueryLoader
alias Disclist.Craigslist.QueryScraper
alias Disclist.Craigslist.Result
alias Disclist.Craigslist.ScraperSupervisor
alias Disclist.Repo
import Ecto.Query

Repo.one(from r in Result, where: r.url == "https://sfbay.craigslist.org/scz/cto/d/santa-cruz-car-for-your-kid-for-the-new/6777033732.html")