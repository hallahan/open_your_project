Basics
======

    bundle install
    cp .env.example .env   # change the secret token in this file to something long and random

Running a rails server
----------------------

    bundle exec foreman run "rails server -p 2222"

Look for your app here: http://www.lvh.me:2222/
(if you change APP_SUBDOMAIN in .env, use the value of that instead of www)

Running a rails console
-----------------------

    bundle exec foreman run rails console

Smallest Federated Wiki
=======================

Open Your Project has close integration with SFW.
Spin up the current OYP-compatible SFW branch thus:

    git clone git@github.com:harlantwood/Smallest-Federated-Wiki.git sfw-oyp
    cd sfw-oyp
    git checkout oyp
    bundle install
    bundle exec foreman run "shotgun -p 1111 server/sinatra/config.ru"

Check that your SFW is running by hitting http://any.subdomain.lvh.me:1111/

Crawling Sites
==============

While you can download pages one at a time through the web interface,
you can also crawl entire sites from the command line:

    bundle exec foreman run "bin/oyp [url to crawl]"

Note that you may wish to adjust MAX_LINKS_PER_SITE in your .env file.
