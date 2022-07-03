# Setup

## Register accounts

* cloudflare
    * buy a domain
    * setup an email alias
* mailgun
    * setup sending limit
    * configure your domain
* oracle cloud account
    * register
* launch & configure website
    * create oci vault
    * create oci secret - mailgun password
    * create server, add tags, run script
        * domain
        * mailgun_user
        * mailgun_domain
        * mailgun_pass_oci
    * launch server, run script
    * configure cloudflare dns
    * setup server
