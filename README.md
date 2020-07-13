## Social9 Comments

Social9 implements the comment service using an open-source project **Commento**. 

## Development Setup
**Start the Database**
This is exposed to `localhost:5432`
```bash
$ docker-compose up db
```

### Build Source Code
```bash
$ make prod
```

### Run Source Code
Export the following environment variables in a `.env` file.
```bash
COMMENTO_ORIGIN=<Origin Address>
COMMENTO_PORT=8080

COMMENTO_POSTGRES=postgres://postgres:postgres@localhost:5432/commento?sslmode=disable
POSTGRES_DB=commento
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

COMMENTO_SMTP_HOST=<Mail Host>
COMMENTO_SMTP_PORT=<Mail Port>
COMMENTO_SMTP_USERNAME=<Maili Username>
COMMENTO_SMTP_PASSWORD=<Mail Password>
COMMENTO_SMTP_FROM_ADDRESS=<Mail From Address>

COMMENTO_GOOGLE_KEY=<Google App Key For OAuth>
COMMENTO_GOOGLE_SECRET=<Google App Secret>
COMMENTO_GITHUB_KEY=<Github App Key For OAuth>
COMMENTO_GITHUB_SECRET=<Github App Secret>

COMMENTO_IDP_ENDPOINT=<LoginRadius IDP En Endpoint>
COMMENTO_IDP_APIKEY=<LoginRadius App API Key>
```

**Start the services**
```bash
$ make prod
$ source .env && ./build/prod/commento
```

### Commento - OpenSource

##### [Homepage](https://commento.io) &nbsp;&ndash;&nbsp; [Demo](https://demo.commento.io) &nbsp;&ndash;&nbsp; [Documentation](https://docs.commento.io) &nbsp;&ndash;&nbsp; [Contributing](https://docs.commento.io/contributing/) &nbsp;&ndash;&nbsp; [#commento on Freenode](http://webchat.freenode.net/?channels=%23commento)

Commento is a platform that you can embed in your website to allow your readers to add comments. It's reasonably fast lightweight. Supports markdown, import from Disqus, voting, automated spam detection, moderation tools, sticky comments, thread locking, OAuth login, single sign-on, and email notifications.

###### How is this different from Disqus, Facebook Comments, and the rest?

Most other products in this space do not respect your privacy; showing ads is their primary business model and that nearly always comes at the users' cost. Commento has no ads; you're the customer, not the product. While Commento is [free software](https://www.gnu.org/philosophy/free-sw.en.html), in order to keep the service sustainable, the [hosted cloud version](https://commento.io) is not offered free of cost. Commento is also orders of magnitude lighter than alternatives.

###### Why should I care about my readers' privacy?

For starters, your readers value their privacy. Not caring about them is disrespectful and you will end up alienating your audience; they won't come back. Disqus still isn't GDPR-compliant (according to their <a href="https://help.disqus.com/terms-and-policies/privacy-faq" title="At the time of writing (28 December 2018)" rel="nofollow">privacy policy</a>). Disqus adds megabytes to your page size; what happens when a random third-party script that is injected into your website turns malicious?

#### Installation

Read the [documentation to get started](https://docs.commento.io/installation/).

#### Contributing

If this is your first contribution to Commento, please go through the [contribution guidelines](https://docs.commento.io/contributing/) before you begin. If you have any questions, join [#commento on Freenode](http://webchat.freenode.net/?channels=%23commento).
