# README

## Installation

This project requires jruby. I suggest you use [rvm](rvm.io) to insatll it.
I suggest you install it with

```
$ \curl -L https://get.rvm.io | bash -s stable --rails
```

After rvm is installed and configured install jruby with

```
$ rvm install jruby
```

## Database initialisation
To get a copy of the graph database run

```
$ rake wiki:get
$ rake wiki:parse:pages
$ # rake wiki:parse:links #TODO: This doesn't work yet
```

This will take a while. I am working on this.
