events = require './index'

beforeEach ->
  unless events.isApplied(this) then events(this)

afterEach ->
  @destroy()
