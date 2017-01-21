path = require 'path'
helpers = require 'atom-linter'
escapeHtml = require 'escape-html'
co = require 'co'
dockerHelper = require 'atom-docker-linter'

DEFAULT_LOCATION = {line: 1, column: 1, length: 0}
DEFAULT_ARGS = [
  '--cache', 'false',
  '--force-exclusion',
  '--format', 'json',
  '--stdin',
  '--display-style-guide',
]
DEFAULT_MESSAGE = 'Unknown Error'
WARNINGS = new Set(['refactor', 'convention', 'warning'])

extractUrl = (message) ->
  [message, url] = message.split /\ \((.*)\)/, 2
  {message, url}

formatMessage = ({message, cop_name, url}) ->
  formatted_message = escapeHtml(message or DEFAULT_MESSAGE)
  formatted_cop_name =
    if cop_name?
      if url?
        " (<a href=\"#{escapeHtml url}\">#{escapeHtml cop_name}</a>)"
      else
        " (#{escapeHtml cop_name})"
    else
      ''
  formatted_message + formatted_cop_name

lint = (editor) ->
  filePath = editor.getPath()
  rootPath = path.dirname(helpers.find(filePath, 'docker-compose.yml'))

  co ->
    rubocopContainer = yield dockerHelper.findExecutableContainer(['bundle', 'exec', 'rubocop', '-v'], rootPath)
    {stdout, stderr} = yield dockerHelper.dockerExec(
      rubocopContainer,
      ['bundle', 'exec', 'rubocop'].concat(DEFAULT_ARGS, path.relative(rootPath, filePath)),
      {stream: 'both', stdin: editor.getText()}
    )
    parsed = try JSON.parse(stdout)
    throw new Error stderr or stdout unless typeof parsed is 'object'
    (parsed.files?[0]?.offenses or []).map (offense) ->
      {cop_name, location, message, severity} = offense
      {message, url} = extractUrl message
      {line, column, length} = location or DEFAULT_LOCATION
      type: if WARNINGS.has(severity) then 'Warning' else 'Error'
      html: formatMessage {cop_name, message, url}
      filePath: filePath
      range: [[line - 1, column - 1], [line - 1, column + length - 1]]

linter =
  name: 'RuboCop'
  grammarScopes: [
    'source.ruby'
    'source.ruby.rails'
    'source.ruby.rspec'
    'source.ruby.chef'
  ]
  scope: 'file'
  lintOnFly: true
  lint: lint

module.exports =
  provideLinter: -> linter
