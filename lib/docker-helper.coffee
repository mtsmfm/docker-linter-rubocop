helpers = require 'atom-linter'
co = require 'co'

findExecutableContainer = (commands, cwd) ->
  result = yield helpers.exec('docker-compose', ['ps', '-q'], {stream: 'both', cwd: cwd})
  composeContainers = result.stdout.split("\n")
  result = yield helpers.exec('docker', ['ps', '-q'], {stream: 'both', cwd: cwd})
  runningContainers = result.stdout.split("\n")
  executableContainers = composeContainers.filter (cc) ->
    runningContainers.some (rc) ->
      cc.startsWith(rc)

  (yield Promise.all(executableContainers.map (c) ->
    co ->
      {container: c, result: (yield dockerExec(c, commands)).exitCode == 0}
  )).find((result) -> result).container

dockerExec = (container, commands, options={stream: 'both'}) ->
  yield helpers.exec('docker', ['exec', '-i', container].concat(commands), options)

module.exports = {
  findExecutableContainer,
  dockerExec
}
