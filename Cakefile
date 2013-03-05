{spawn, exec} = require 'child_process'

_ = require 'lodash'

nodeBinary = (name) -> "node_modules/.bin/#{name}"

launch = (cmd, options=[], callback) ->
  env = _.extend process.env,
    NODE_PATH: "./lib:#{process.env.NODE_PATH}"
  proc = spawn cmd, options, env
  proc.stdout.pipe(process.stdout)
  proc.stderr.pipe(process.stderr)
  proc.on 'exit', (status) -> callback?() if status is 0

test = (options=[], callback) ->
  if typeof options is 'function'
    callback = options
    options = []

  options.push '--compilers'
  options.push 'coffee:coffee-script'
  options.push '--colors'
  options.push '-R'
  options.push 'spec'

  launch nodeBinary('mocha'), options, callback

task 'test', 'Run tests', -> test()
task 'test:watch', 'Watch tests', -> test ['-w']
