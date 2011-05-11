# Skeeter

## What is it?

Skeeter is a small asynchronous web service that takes in image urls and returns ascii art.
Convert this:

![Original
image](https://github.com/blakesmith/skeeter/raw/master/images/moose.png)

Into this:

![Converted
image](https://github.com/blakesmith/skeeter/raw/master/images/moose-ascii.jpg)

You make a request to it like so:

  http://skeeter.blakesmith.me/?image_url=http://www.softicons.com/download/animal-icons/animal-icons-by-martin-berube/png/128/moose.png&width=100

And it spits out the ascii art! Magic!

## Why do this?

I wanted a way to have images pasted in campfire via my
[flamethrower](http://github.com/blakesmith/flamethrower) IRC gateway converted
to ascii for inline display. Rather than add extra dependencies and additional
overhead to flamethrower itself, it makes a simple non-blocking service call
using EM-HttpRequest.

This was also an exercise in learning more about Ruby 1.9 Fibers, the
[Goliath](http://www.igvita.com/2011/03/08/goliath-non-blocking-ruby-19-web-server/)
webserver, and last but certainly not least [ZeroMQ](http://www.zeromq.org/)
(Only the sweetest most awesomely mind expanding piece of software ever).
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

A user makes a request via HTTP to the Goliath webserver (skeeter.rb). Each web
request is wrapped in a Ruby 1.9 Fiber. In this simplified case, think of a
Fiber as a lightweight Thread that can be scheduled manually. The Fiber is
created, parses the request, puts a JSON message onto the ZeroMQ socket and then
goes to sleep. The message is routed via the dispatcher to a worker on the
backend using fair queueing (think of it like a load balancer). The worker takes
the request off the socket, does the work (converting the image) and then sends
a response back across the socket. The dispatcher routes the response back to
the original requester. At this point, EventMachine wakes up the sleeping
request Fiber with the response, which is sent to the client. Voilà! ASCII
Magic!

## Why it's awesome

Here's why I get so excited about this stuff: Using ZeroMQ and an awesome async
webserver, we are able to glue together a relatively complicated architecture
with very little code. Not only that, but the webserver itself can be completely
non-blocking while the backend can make blocking calls without hurting request
throughput. Scaling this system is really simple: we just add more worker
processes (not even any config changes needed). A new worker simply joins the
ZeroMQ socket and begins processing requests. This is all transparently handled
by ZeroMQ. Workers can join and leave the worker pool at will and ZeroMQ will
handle it all for us.

When our service really starts to take off, we can even spin up more worker
processes on other nodes in the networke and ZeroMQ can handle communicating
with them transparently over TCP.

If you haven't played with ZeroMQ, I suggest you make up a good reason to try it
out.

## Install

### Native dependencies

- jp2a (get it here: http://csl.sublevel3.org/jp2a/)
- zeromq (OS X users can 'brew install zeromq')

### Ruby dependencies

Make sure you have the bundler gem installed and do 'bundle install'. This will
automatically install all the necessary ruby dependencies.

### Running

Each ruby process has its own controller script (in the controllers/ direction)
that will launch it as a daemon. You must use Ruby 1.9 (for fiber support).

- skeeter_controller.rb - Start the Goliath web server on port 9000. (ruby
  controllers/skeeter_controller.rb start)
- dispatcher_controller.rb - Start the dispatcher. (ruby
  controllers/dispatcher_controller.rb)
- worker_controller.rb - Start the forked worker processes, 2 by default (ruby
  controllers/worker_controller.rb)
 
There are corresponding capistrano tasks to start and stop each one of these
daemon processes.

## Author

Skeeter is written by Blake Smith <blakesmith0@gmail.com>.

