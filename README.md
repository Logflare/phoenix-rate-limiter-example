# PhxLimit
I needed a project for ElixirConf 2020. This is it!

This rate limiter uses Phoenix, Phoenix PubSub and ETS to share request per second data of each node, to each node across the cluster. Those data are cached locally and checked on each request, rate limiting the requestor, or not.

This project is based off of the rate limiter we're using for [Logflare](https://logflare.app), which is today doing around 500 million requests per day, often peaking at 600,000 requests per minute on a 4 node cluster.

If you think this is cool, and you're interested in not burning so much cash on logging, check out s[Logflare](https://logflare.app) where you can log 12,960,000 events per month for free.

## Thanks
 * To the people who are behind Elixir and Phoenix.
 * To Gigalixir for making awesome hosting for Elixir, and making clustering so easy.
 
## Setup
  * Set LOGFLARE_API_KEY

## Learn more about Phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
