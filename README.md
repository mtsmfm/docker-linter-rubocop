# linter-docker-rubocop

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) provides
an interface to [rubocop](https://github.com/bbatsov/rubocop) on docker. It will be used
with files that have the “Ruby” syntax.

You must run a container installed `rubocop` via `dodcker-compose`
because linter-docker-rubocop use `docker exec` to run `rubocop`.

## Installation

Linter package must be installed on your docker container in order to use this plugin. If Linter is not
installed, please follow the instruction.

### `docker-compose` installation

Follow https://docs.docker.com/engine/installation/.

### `rubocop` installation

Before using this plugin, you must ensure that `rubocop` on your docker container.

```
$ cd /path/to/your/project
$ touch docker-compose.yml
$ # edit your docker-compose.yml to run ruby
$ docker-compose run ruby bundle init
$ # add `gem 'rubocop'` to your Gemfile
$ docker-compose run ruby bundle init
$ docker-compose run ruby 'sh -c "trap : TERM INT; sleep infinity & wait"' # run your container forever because this package will use `docker exec` to run `rubocop`
```

### Plugin installation

```shell
apm install linter-docker-rubocop
```

## TODO

- Extract docker-helper.coffee as npm
- Cache container name
- Fallback to `docker run` if there are no running container
- Better error messages
  - docker not found
  - docker-compose not found
  - docker-compose.yml not found
  - rubocop not found
  - Running container not found

## Contributing

If you would like to contribute enhancements or fixes, please do the following:

1.  Fork the plugin repository.
2.  Hack on a separate topic branch created from the latest `master`.
3.  Commit and push the topic branch.
4.  Make a pull request.
5.  Welcome to the club!

Please note that modifications should follow these coding guidelines:

-   Indent is 2 spaces.
-   Code should pass the `coffeelint` linter.
-   Vertical whitespace helps readability, don’t be afraid to use it.

Thank you for helping out!

## Special Thanks

This package is started as fork off https://github.com/AtomLinter/linter-rubocop.
