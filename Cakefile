honkCake = require 'honk-cake'

honkCake.all()
# nodeBinary = (name) -> "node_modules/.bin/#{name}"
# 
# strip = (s) -> s.replace(/^\s+|\s+$/g, '')
# 
# stdout = (cmd, args, callback) ->
#   proc = spawn cmd, args
#   buf = ''
#   proc.stdout.on 'data', (data) -> buf += data
#   proc.on 'close', -> callback?(buf)
# 
# launch = (cmd, options=[], callback) ->
#   env = _.extend process.env,
#     NODE_PATH: "./lib:#{process.env.NODE_PATH}"
#   proc = spawn cmd, options, env
#   proc.stdout.pipe(process.stdout)
#   proc.stderr.pipe(process.stderr)
#   proc.on 'exit', (status) -> callback?() if status is 0
# 
# test = (options=[], callback) ->
#   if typeof options is 'function'
#     callback = options
#     options = []
# 
#   options.push '--compilers'
#   options.push 'coffee:coffee-script'
#   options.push '--colors'
#   options.push '-R'
#   options.push 'spec'
# 
#   launch nodeBinary('mocha'), options, callback
# 
# doc = (output, callback) ->
#   output or= './doc'
#   launch nodeBinary('docco'), ['./lib/index.coffee', '-o', output], callback
# 
# docSite = (callback) ->
#   stdout 'git', ['rev-parse', '--abbrev-ref', 'HEAD'], (stdout) ->
#     branch = strip(stdout)
#     stageTo = "/tmp/site/#{branch}"
# 
#     doc stageTo, ->
#       console.log "Staged #{branch} to #{stageTo}"
# 
#     console.log '$ checking out', 'gh-pages'
#     spawn 'git', ['checkout', 'gh-pages']
# 
#     console.log '$ checking out', branch
#     spawn 'git', ['checkout', branch]
# 
# 
# task 'test', 'Run tests', -> test()
# task 'test:watch', 'Watch tests', -> test ['-w']
# task 'doc', 'Generate documentation', -> doc()
# task 'doc:site', 'Generate documentation site', -> docSite()
