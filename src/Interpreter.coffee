'use strict'

Interpreter = ->
  @playfield = null
  @pathSet = null

  # used for statistics/debugging
  @stats =
    compileCalls: 0
    jumpsPerformed: 0

  return


Interpreter::_getPath = (x, y, dir) ->
  path = new bef.Path()
  pointer = new bef.Pointer x, y, dir, @playfield.getSize()

  loop
    if not @playfield.isInside pointer.x, pointer.y
      path.endingOutside = true
      return [path]

    currentChar = @playfield.getAt pointer.x, pointer.y
    pointer.turn currentChar

    if path.has pointer.x, pointer.y, pointer.dir
      splitPosition = (path.getEntryAt pointer.x, pointer.y, pointer.dir).index
      if splitPosition > 0
        initialPath = path.prefix splitPosition
        loopingPath = path.suffix splitPosition
        return [initialPath, loopingPath]
      else
        return [path]

    if currentChar == '|' or currentChar == '_' or currentChar == '?' or currentChar == '@'
      return [path]

    path.push pointer.x, pointer.y, pointer.dir, currentChar

    pointer.advance()


Interpreter::put = (x, y, e, currentX, currentY, currentDir, currentIndex) ->
  paths = @playfield.getPathsThrough x, y
  paths.forEach (path) =>
    @pathSet.remove path
    @playfield.removePath path
  @playfield.setAt x, y, e

  if @currentPath.has x, y, '^'
    index = (@currentPath.getEntryAt x, y, '^').index
    if index > currentIndex
      @runtime.flags.pathInvalidatedAhead = true
      @runtime.flags.exitPoint =
        x: currentX
        y: currentY
        dir: currentDir
      return

  if @currentPath.has x, y, '<'
    index = (@currentPath.getEntryAt x, y, '<').index
    if index > currentIndex
      @runtime.flags.pathInvalidatedAhead = true
      @runtime.flags.exitPoint =
        x: currentX
        y: currentY
        dir: currentDir
      return

  if @currentPath.has x, y, 'v'
    index = (@currentPath.getEntryAt x, y, 'v').index
    if index > currentIndex
      @runtime.flags.pathInvalidatedAhead = true
      @runtime.flags.exitPoint =
        x: currentX
        y: currentY
        dir: currentDir
      return

  if @currentPath.has x, y, '>'
    index = (@currentPath.getEntryAt x, y, '>').index
    if index > currentIndex
      @runtime.flags.pathInvalidatedAhead = true
      @runtime.flags.exitPoint =
        x: currentX
        y: currentY
        dir: currentDir
      return


Interpreter::execute = (@playfield, options) ->
  options ?= {}
  options.jumpLimit ?= -1
  options.compiler ?= bef.BasicCompiler

  @stats.compileCalls = 0
  @stats.jumpsPerformed = 0

  @pathSet = new bef.PathSet()
  @runtime = new bef.Runtime @
  pointer = new bef.Pointer 0, 0, '>', @playfield.getSize()

  loop
    if @stats.jumpsPerformed == options.jumpLimit
      break # artificial limit to prevent potentially non-breaking loops
    else
      @stats.jumpsPerformed++

    @currentPath = @pathSet.getStartingFrom pointer.x, pointer.y, pointer.dir
    if not @currentPath
      newPaths = @_getPath pointer.x, pointer.y, pointer.dir
      newPaths.forEach (newPath) =>
        @stats.compileCalls++
        options.compiler.compile newPath
        if newPath.list.length
          @pathSet.add newPath
          playfield.addPath newPath

    @currentPath ?= newPaths[0]
    @currentPath.body @runtime # executing the compiled path
    if @runtime.flags.pathInvalidatedAhead
      @runtime.flags.pathInvalidatedAhead = false
      exitPoint = @runtime.flags.exitPoint
      pointer.set exitPoint.x, exitPoint.y, exitPoint.dir
      pointer.advance()
      continue

    if @currentPath.list.length
      pathEndPoint = @currentPath.getEndPoint()
      pointer.set pathEndPoint.x, pathEndPoint.y, pathEndPoint.dir
      pointer.advance()
    currentChar = @playfield.getAt pointer.x, pointer.y

    if currentChar == '|'
      if @runtime.pop() == 0
        pointer.turn '^'
      else
        pointer.turn 'v'
      pointer.advance()
    else if currentChar == '_'
      if @runtime.pop() == 0
        pointer.turn '<'
      else
        pointer.turn '>'
      pointer.advance()
    else if currentChar == '?'
      pointer.turn '^<v>'[Math.random() * 4 | 0]
      pointer.advance()
    else if currentChar == '@'
      break # program ended
    else
      pointer.turn currentChar

  return


window.bef ?= {}
window.bef.Interpreter = Interpreter