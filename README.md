# Skeeter

## What is it?

Skeeter is a small asynchronous web service that takes in image urls and returns ascii art.
You make a request to it like so:

  http://skeeter.blakesmith.me/?image_url=http://www.softicons.com/download/animal-icons/animal-icons-by-martin-berube/png/128/moose.png&width=100

And it spits out the ascii art! Magic!

## Why do this?

I wanted a way to convert images pasted in campfire via my
[flamethrower](http://github.com/blakesmith/flamethrower) IRC gateway to be
converted to ascii for inline display. Rather than add extra dependencies and
additional overhead to flamethrower itself, it makes a simple non-blocking
service call using EM-HttpRequest.

This was also an exercise in learning more about Ruby 1.9 Fibers, the
[Goliath](http://www.igvita.com/2011/03/08/goliath-non-blocking-ruby-19-web-server/)
webserver, and last but certainly not least [ZeroMQ](http://www.zeromq.org/)
(Only the sweetest most awesomely mind expanding piece of software ever)
Put all these components together and you can build something pretty freaking
sweet.

## How does it work?

### All the moving pieces

Each one of the following represents an independent ruby process that
communicates via message passing with ZeroMQ.

- skeeter.rb - The Goliath webserver definition. Similar in style to a Rack app.
  Feeds requests into dispatcher.rb
- dispatcher.rb - Lightweight process that takes requests from the webserver via
  a ZeroMQ socket and evenly distributes them to a pool of workers connected to
  a backend ZeroMQ socket.
- worker.rb - Worker process. Listens for requests on a ZeroMQ socket and shells
  out to jp2a to do the actual image conversion. Responds on the socket with the
  converted ascii.
- jp2a - C program that does the actual ascii conversion.

### Request lifecycle

A user makes a request via HTTP to the Goliath webserver (skeeter.rb)
