## MyCrypto.fun

MyCrypto.fun is a simple web app that takes your Cyrypto exchange account and displays a publicly shareable real-time breakdown of your portfolio -- no amounts, just % holding.

### Getting Started
1. Clone this repo
2. `bundle install`
3. Get your Exchange API Key
4. Create a Heroku app `herkou apps:create`
5. Push to your new Heroku app
6. Set your (Environment Variables)[#environment-variables]
7. Try it out!

### Environment Variables
`BITTREX_API_KEY`: Your Bittrex API key

`BITTREX_SECRET`: Your Bittrex secret key

`MYCRYPTO_NAME`: Your name for display (full name)

`MYCRYPTO_BIO`: You bio for the home page

`MYCRYPTO_TWITTER`: Your Twitter handle

`MYCRYPTO_DEBUG`: Enables Charles proxy

`MYCRYPTO_FAKE_DATA`: Uses only a status response for wallets (offline friendly)

### Supported Exchanges
- Bittrex

### Finding your API Key

#### Bittrex
TODO: How do you get your Bittrex API key

### Contributing
Contributions welcome! Particularly useful right now are:

- Adding additional exchanges
- Figure out strategy for mycrypto.fun/
   - Everything is parameterised by how do we handle multi-tenancy?
   - Wallet Addresses vs. API Keys?
- Add movement_30d to real API calls (the UI is ready)
- Allow static (ENV?) positions that aren't on Bittrex (e.g. 12.5 BTC in cold storage)

### Acknowledgements
- Thanks to [Felix Krause](https://twitter.com/KrauseFx) for the Bittrex Exchange code
