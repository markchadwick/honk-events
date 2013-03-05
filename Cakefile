{spawn, exec} = require 'child_process'


test = (opts, callback) ->
  options = [
    '--compilers', 'coffee:coffee-script',
    '--recursive',
    './test/',
  ]
  options.push(o) for o in opts
  proc = spawn 'mocha', options, stdio:  'inherit'
  proc.stdout = process.stdout
  proc.stderr = process.stderr
  process.on 'exit', (status) ->
    callback?(status)


task 'test', 'Run Tests', ->
  test([])

task 'watch', 'Watch Tests', ->
  test(['--watch'])
