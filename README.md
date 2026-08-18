# Ember Progress

A practice roadmap for building Ember

## Stack


| Piece              | Library                                                                                             | Owns                                               |
| ------------------ | --------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| core               | [Zig Std](https://ziglang.org/documentation/0.16.0/std/)                                            | core editor and render logic                       |
| Window, input, GPU | [sokol-zig](https://github.com/floooh/sokol-zig) (`sokol.app`, `sokol.gfx`)                         | cross platform GPU drawing, input and window logic |
| UI layout          | [clay](https://github.com/nicbarker/clay) via [zclay](https://github.com/johan0A/clay-zig-bindings) | UI layout logic                                    |




## 1. Basic File I/O

Work lives in `practice/basic-io`.

- [x] Open a file - `cwd.openFile(io, "hello.txt", .{});`
- [x] Read an entire file into memory - `std.Io.Dir.cwd().readFileAlloc(io,path,gpa,.unlimited or .limited());`
- [x] Print file contents to terminal - `std.debug.print()`
- [x] Open a file from another directory - `"../hello.txt"`
- [x] Handle relative paths - `cwd.readFileAlloc + "../hello.txt"`

- [x] Handle absolute paths - `cwd.readFileAlloc + "C:/Users/AbhinavPutta/Desktop/projects/ember/hello.txt"`

- [x] Get file size - `std.Io.Dir.cwd().statFile().size or cwd.readFileAlloc().len`
- [x] Get file metadata - `std.Io.Dir.cwd().statFile()`
- [x] Create a file - `basic-io.helper.createEmptyfile`
- [x] Write to a file - `basic-io.helper.saveFile`
- [ ] Append to a file - `Not needed now`
- [x] Overwrite a file - `basic-io.helper.saveFile`
- [x] Rename a file 
- [x] Delete a file
- [x] Create a directory
- [x] List files in a directory
- [x] Recursively walk a directory



### Project: `ember-cat` - implemented

- [x] `ember-cat file.txt`
- [x] Print file contents
- [x] Print line numbers
- [x] Show useful error if file does not exist
- [x] Support files outside current working directory

---



## 2. Text Processing



### Project: `ember-grep`

- [x] Count lines in a file - use smid later in project
- [x] Find a substring
- [x] Print matching lines
- [x] Print matching line numbers
- [x] Search case-insensitively
- [x] Search multiple files
- [ ] Search an entire directory
- [ ] Skip binary files

Example:

```powershell
ember-grep "pub fn" src/
```

---



## 3. Build a Text Buffer



### Project: `ember-buffer`

- [ ] Load file contents into a mutable buffer
- [ ] Read byte at position
- [ ] Insert one byte
- [ ] Insert a string
- [ ] Delete one byte
- [ ] Delete a range
- [ ] Replace a range
- [ ] Find start of line
- [ ] Find end of line
- [ ] Convert line/column to byte offset
- [ ] Convert byte offset to line/column
- [ ] Save buffer back to file
- [ ] Add tests for every buffer operation

---



## 4. Build a Better Text Buffer



### Project: `gap-buffer`

- [ ] Implement a gap buffer
- [ ] Create an initial gap
- [ ] Insert text at gap
- [ ] Delete text around gap
- [ ] Move gap left
- [ ] Move gap right
- [ ] Grow the gap
- [ ] Extract complete document text
- [ ] Load file into gap buffer
- [ ] Save gap buffer to file
- [ ] Benchmark against simple contiguous buffer

---



## 5. Sokol Window



### Project: `ember-window`

- [ ] Add `sokol-zig` with `zig fetch --save=sokol git+https://github.com/floooh/sokol-zig.git`
- [ ] Wire `sokol` into `build.zig`
- [ ] Create a `sokol.app` window
- [ ] Set title to `Ember`
- [ ] Set initial window size
- [ ] Enable high-DPI
- [ ] Implement `init` / `frame` / `event` / `cleanup`
- [ ] Handle quit / close
- [ ] Handle resize
- [ ] Handle iconified / restored
- [ ] Exit cleanly in `cleanup`



### Milestone

- [ ] `zig build run` opens Ember

---



## 6. Keyboard Input



### Project: `ember-input`

- [ ] Detect key down
- [ ] Detect key up
- [ ] Detect text input
- [ ] Detect Ctrl
- [ ] Detect Shift
- [ ] Detect Alt
- [ ] Detect Enter
- [ ] Detect Tab
- [ ] Detect Backspace
- [ ] Detect Delete
- [ ] Detect arrow keys
- [ ] Detect Home
- [ ] Detect End
- [ ] Detect Page Up
- [ ] Detect Page Down



### Ember Event Layer

- [ ] Convert `sokol.app.Event` into Ember events
- [ ] Keep sokol-specific values out of editor code

Example:

```text
sapp.Event
     ↓
platform.zig
     ↓
Event.key_down
     ↓
editor.zig
```

---



## 7. Mouse Input



### Project: `ember-mouse`

- [ ] Track mouse position
- [ ] Detect left click
- [ ] Detect right click
- [ ] Detect middle click
- [ ] Detect mouse wheel
- [ ] Detect drag
- [ ] Detect double click
- [ ] Convert mouse coordinates into editor coordinates
- [ ] Feed pointer state to clay for chrome hit-testing

---



## 8. Sokol Rendering



### Project: `ember-render`

- [ ] Set up `sokol.gfx` in `init`
- [ ] Begin a swapchain pass each frame
- [ ] Clear the window background
- [ ] Draw a rectangle
- [ ] Draw a line
- [ ] Draw a cursor rectangle
- [ ] Redraw every frame and after resize
- [ ] Shut down `sokol.gfx` in `cleanup`
- [ ] Build a small renderer interface over sokol

Example:

```zig
sg.beginPass(.{ .swapchain = sglue.swapchain() });
renderer.clear();
renderer.drawRect(...);
sg.endPass();
sg.commit();
```

---



## 9. Text Rendering



### Project: `ember-font`

- [ ] Load a monospace font (sokol fontstash or a small GPU atlas)
- [ ] Draw one character
- [ ] Draw a string
- [ ] Draw multiple lines
- [ ] Measure character width
- [ ] Measure line height
- [ ] Calculate baseline
- [ ] Handle DPI with `sapp.dpiScale()`
- [ ] Render text cleanly after resizing
- [ ] Use the same font metrics for clay text measurement later



### Milestone

- [ ] Ember displays `Hello, Ember`
- [ ] Ember displays 100 lines of text

---



## 10. Clay UI Shell

Clay owns editor chrome. Ember owns the text viewport.

### Project: `ember-shell`

- [ ] Add clay via `zig fetch --save git+https://github.com/johan0A/clay-zig-bindings`
- [ ] Import `zclay` in `build.zig`
- [ ] Create a clay arena
- [ ] Initialize clay with the sokol window size
- [ ] Set clay text measurement from Ember font metrics
- [ ] Begin / end a layout each frame
- [ ] Build a root layout: explorer | editor | status bar
- [ ] Render clay rectangles with sokol
- [ ] Render clay text with sokol
- [ ] Pass pointer state into clay
- [ ] Handle hover
- [ ] Handle click on clay elements
- [ ] Resize the layout with the window
- [ ] Ask clay for the editor rectangle
- [ ] Draw Ember text into that rectangle only



### Milestone

- [ ] Ember shows a clay shell around an empty editor pane

---



## 11. File Viewer



### Project: `ember-view`

- [ ] Pass filename to Ember

```powershell
ember.exe src/main.zig
```

- [ ] Open file
- [ ] Read contents
- [ ] Split contents into lines
- [ ] Render file inside the clay editor rectangle
- [ ] Show filename in the sokol window title
- [ ] Handle empty file
- [ ] Handle missing file
- [ ] Handle large file



### Milestone: Ember 0.1

- [ ] Open a source file
- [ ] Display it in a sokol window inside the clay shell

---



## 12. Scrolling and Viewport



### Project: `ember-viewport`

- [ ] Store vertical scroll position
- [ ] Store horizontal scroll position
- [ ] Calculate first visible line
- [ ] Calculate last visible line
- [ ] Render only visible lines
- [ ] Scroll with mouse wheel
- [ ] Scroll with Page Up
- [ ] Scroll with Page Down
- [ ] Handle window resize
- [ ] Clip the viewport to the clay editor rectangle
- [ ] Keep rendering independent of total file size



### Goal

For a 500,000-line file:

- [ ] Render only the lines currently visible on screen

---



## 13. Cursor



### Project: `ember-cursor`

- [ ] Render cursor
- [ ] Move left
- [ ] Move right
- [ ] Move up
- [ ] Move down
- [ ] Move to start of line
- [ ] Move to end of line
- [ ] Ctrl+Left
- [ ] Ctrl+Right
- [ ] Page Up
- [ ] Page Down
- [ ] Click somewhere to move cursor there
- [ ] Keep cursor visible while scrolling

---



## 14. Editing



### Project: `ember-edit`

- [ ] Type character
- [ ] Insert text at cursor
- [ ] Enter creates newline
- [ ] Backspace deletes previous character
- [ ] Delete removes next character
- [ ] Tab inserts indentation
- [ ] Cursor moves after editing
- [ ] Mark buffer as modified
- [ ] Save with Ctrl+S
- [ ] Reload saved file



### Milestone: Ember 0.2

- [ ] Open file
- [ ] Navigate file
- [ ] Type
- [ ] Delete
- [ ] Save

Ember is now a real text editor.

---



## 15. Selection



### Project: `ember-selection`

- [ ] Shift+Left
- [ ] Shift+Right
- [ ] Shift+Up
- [ ] Shift+Down
- [ ] Mouse drag selection
- [ ] Highlight selected text
- [ ] Ctrl+A
- [ ] Delete selection
- [ ] Replace selection by typing
- [ ] Double-click selects word

---



## 16. Clipboard



### Project: `ember-clipboard`

- [ ] Copy selected text
- [ ] Cut selected text
- [ ] Paste text
- [ ] Ctrl+C
- [ ] Ctrl+X
- [ ] Ctrl+V
- [ ] Paste multiline text
- [ ] Copy with `sapp.setClipboardString()`
- [ ] Paste with `sapp.getClipboardString()`

---



## 17. Undo and Redo



### Project: `ember-history`

- [ ] Record insert operations
- [ ] Record delete operations
- [ ] Undo insert
- [ ] Undo delete
- [ ] Redo
- [ ] Ctrl+Z
- [ ] Ctrl+Y
- [ ] Restore cursor position
- [ ] Group normal typing into one undo action
- [ ] Group repeated backspaces
- [ ] Clear redo history after a new edit

---



## 18. UTF-8 Editing



### Project: `ember-unicode`

- [ ] Open UTF-8 files
- [ ] Move cursor across multi-byte characters
- [ ] Backspace multi-byte characters correctly
- [ ] Delete multi-byte characters correctly
- [ ] Select UTF-8 text correctly
- [ ] Handle accented characters
- [ ] Handle emoji
- [ ] Understand grapheme boundaries
- [ ] Keep byte offset separate from visual column

---



## 19. Fast Line Index



### Project: `ember-lines`

- [ ] Build line index when opening file
- [ ] Get byte offset for a line
- [ ] Get line number from byte offset
- [ ] Update index after inserting newline
- [ ] Update index after deleting newline
- [ ] Avoid rescanning whole file on cursor movement
- [ ] Test with 100,000+ lines

---



## 20. Multiple Files



### Project: `ember-buffers`

- [ ] Open more than one file
- [ ] Assign each buffer an ID
- [ ] Track active buffer
- [ ] Switch active buffer
- [ ] Close buffer
- [ ] Detect unsaved changes
- [ ] Create empty buffer
- [ ] Save As

---



## 21. Tabs



### Project: `ember-tabs`

- [ ] Layout the tab bar with clay
- [ ] Show filename
- [ ] Show modified indicator
- [ ] Click tab
- [ ] Close tab
- [ ] Ctrl+Tab
- [ ] Reorder tabs

---



## 22. File Explorer



### Project: `ember-explorer`

- [ ] Open project directory
- [ ] List files
- [ ] List directories
- [ ] Display the tree with clay
- [ ] Expand directory
- [ ] Collapse directory
- [ ] Open file
- [ ] Keyboard navigation
- [ ] Mouse navigation
- [ ] Ignore `.git`
- [ ] Toggle explorer with `Alt+E`

---



## 23. Fuzzy File Finder



### Project: `ember-find`

- [ ] Collect project files
- [ ] Implement subsequence matching
- [ ] Build fuzzy-match scoring
- [ ] Rank results
- [ ] Prefer consecutive matches
- [ ] Prefer filename matches
- [ ] Show the search popup with clay
- [ ] Search while typing
- [ ] Navigate results
- [ ] Open selected file
- [ ] Bind to `Alt+F`

---



## 24. Search Inside Current File



### Project: `ember-search`

- [ ] Ctrl+F
- [ ] Layout the find bar with clay
- [ ] Search current file
- [ ] Highlight matches
- [ ] Jump to next match
- [ ] Jump to previous match
- [ ] Case-sensitive search
- [ ] Replace
- [ ] Replace all

---



## 25. Project Grep



### Project: `ember-grep-ui`

- [ ] Search every project file
- [ ] Layout the results panel with clay
- [ ] Display filename
- [ ] Display line number
- [ ] Display matching text
- [ ] Navigate results
- [ ] Open matching file
- [ ] Jump to matching line
- [ ] Ignore binary files
- [ ] Ignore `.git`

---



## 26. Syntax Highlighting



### Project: `ember-lexer`

Start by writing your own Zig lexer.

- [ ] Recognize keywords
- [ ] Recognize identifiers
- [ ] Recognize numbers
- [ ] Recognize strings
- [ ] Recognize comments
- [ ] Recognize operators
- [ ] Recognize punctuation
- [ ] Store token ranges
- [ ] Give each token a type
- [ ] Render token types differently



### Milestone: Ember 0.3

- [ ] Open Zig file
- [ ] Edit Zig file
- [ ] Syntax-highlight Zig file

---



## 27. Command System



### Project: `ember-command`

Instead of hardcoding:

```text
Ctrl+S → save()
```

build:

```text
Ctrl+S
   ↓
Command.save
   ↓
executeCommand()
```

- [ ] Define command IDs
- [ ] Build command dispatcher
- [ ] Map keyboard shortcuts to commands
- [ ] Save command
- [ ] Open command
- [ ] Close command
- [ ] Find command
- [ ] Toggle explorer command
- [ ] Undo command
- [ ] Redo command

---



## 28. Command Palette



### Project: `ember-palette`

- [ ] Open the command palette as a clay popup
- [ ] List commands
- [ ] Fuzzy-search commands
- [ ] Navigate commands
- [ ] Execute selected command
- [ ] Escape closes palette

---



## 29. Status Bar



### Project: `ember-status`

- [ ] Layout the status bar with clay
- [ ] Show current file
- [ ] Show modified state
- [ ] Show line number
- [ ] Show column
- [ ] Show file type
- [ ] Show encoding
- [ ] Show line endings

Example:

```text
main.zig                         Zig | UTF-8 | LF | Ln 42, Col 8
```

---



## 30. Spawn Processes



### Project: `ember-run`

- [ ] Start a child process
- [ ] Pass arguments
- [ ] Set working directory
- [ ] Capture stdout
- [ ] Capture stderr
- [ ] Read exit code
- [ ] Run `zig version`
- [ ] Run `zig build`
- [ ] Display build output inside Ember

---



## 31. Build Output Panel



### Project: `ember-build`

- [ ] Create a bottom panel with clay
- [ ] Run build command
- [ ] Stream output
- [ ] Show stdout
- [ ] Show stderr
- [ ] Scroll output
- [ ] Clear output
- [ ] Parse `file:line:column`
- [ ] Jump from compiler error to source location

---



## 32. Git Integration



### Project: `ember-git`

Start by running the real `git` executable.

- [ ] Detect Git repository
- [ ] Get current branch
- [ ] Run `git status`
- [ ] Parse modified files
- [ ] Display modified files in a clay panel
- [ ] Run `git diff`
- [ ] Render diff
- [ ] Stage file
- [ ] Unstage file
- [ ] Commit

---



## 33. JSON-RPC



### Project: `ember-rpc`

Before touching LSP:

- [ ] Serialize JSON
- [ ] Parse JSON
- [ ] Build JSON-RPC request
- [ ] Assign request IDs
- [ ] Parse JSON-RPC response
- [ ] Match response to request
- [ ] Handle notifications

---



## 34. LSP Transport



### Project: `ember-lsp`

- [ ] Spawn `zls`
- [ ] Connect to its stdin
- [ ] Connect to its stdout
- [ ] Send LSP message
- [ ] Parse `Content-Length`
- [ ] Read complete response
- [ ] Match response IDs
- [ ] Handle notifications
- [ ] Handle language server crash
- [ ] Restart language server

---



## 35. Basic LSP

- [ ] Send `initialize`
- [ ] Send `initialized`
- [ ] Send `textDocument/didOpen`
- [ ] Send `textDocument/didChange`
- [ ] Send `textDocument/didSave`
- [ ] Send `textDocument/didClose`

---



## 36. Diagnostics



### Project: `ember-diagnostics`

- [ ] Receive errors from ZLS
- [ ] Receive warnings
- [ ] Store diagnostics
- [ ] Underline error locations
- [ ] Show diagnostic message
- [ ] Jump to next error
- [ ] Jump to previous error

---



## 37. Go To Definition



### Project: `ember-definition`

- [ ] Request definition from LSP
- [ ] Parse returned location
- [ ] Open target file
- [ ] Jump to target line
- [ ] Jump back to previous location

---



## 38. Hover



### Project: `ember-hover`

- [ ] Detect symbol under cursor
- [ ] Request hover from LSP
- [ ] Render the hover popup with clay
- [ ] Close popup
- [ ] Render basic Markdown returned by LSP

---



## 39. Autocomplete



### Project: `ember-complete`

- [ ] Request completions
- [ ] Display the completion popup with clay
- [ ] Navigate suggestions
- [ ] Accept suggestion
- [ ] Cancel suggestions
- [ ] Apply text edit returned by LSP
- [ ] Display completion documentation



### Milestone: Ember 0.4

- [ ] Diagnostics
- [ ] Hover
- [ ] Go to definition
- [ ] Autocomplete

Ember is now a proper code editor.

---



## 40. Integrated Terminal



### Project: `ember-terminal`

Do this after the editor itself is solid.

- [ ] Learn Windows ConPTY
- [ ] Start shell inside PTY
- [ ] Send keyboard input
- [ ] Receive terminal output
- [ ] Parse ANSI escape sequences
- [ ] Build terminal screen buffer
- [ ] Ask clay for the terminal panel rectangle
- [ ] Render terminal cells with sokol
- [ ] Render terminal cursor
- [ ] Handle colors
- [ ] Handle scrollback
- [ ] Resize PTY with the clay panel
- [ ] Support multiple terminal sessions

---



## 41. Markdown Preview



### Project: `ember-markdown`

- [ ] Detect Markdown file
- [ ] Parse heading
- [ ] Parse paragraph
- [ ] Parse bold
- [ ] Parse italic
- [ ] Parse links
- [ ] Parse code block
- [ ] Layout a preview pane with clay
- [ ] Render preview with sokol
- [ ] Toggle editor/preview

---



## 42. Image Viewer



### Project: `ember-image`

- [ ] Detect image file
- [ ] Decode PNG
- [ ] Decode JPEG
- [ ] Upload the image as a sokol texture
- [ ] Display it in a clay pane
- [ ] Scale to the pane
- [ ] Zoom
- [ ] Pan

---



## 43. Performance Pass



### Project: `ember-fast`

- [ ] Measure startup time
- [ ] Measure idle RAM
- [ ] Measure file-open time
- [ ] Measure typing latency
- [ ] Measure frame time
- [ ] Count allocations while typing
- [ ] Count allocations while rendering
- [ ] Count allocations in the clay layout
- [ ] Remove unnecessary per-frame allocations
- [ ] Test 1 MB source file
- [ ] Test 10 MB source file
- [ ] Test 100 MB source file
- [ ] Profile before optimizing

---



# Major Milestones



## Ember 0.1 — File Viewer

- [ ] Sokol window
- [ ] Clay shell
- [ ] Open file
- [ ] Render file
- [ ] Scroll



## Ember 0.2 — Text Editor

- [ ] Cursor
- [ ] Insert
- [ ] Delete
- [ ] Selection
- [ ] Clipboard
- [ ] Undo/redo
- [ ] Save



## Ember 0.3 — Code Editor

- [ ] Multiple files
- [ ] Tabs
- [ ] File explorer
- [ ] Fuzzy finder
- [ ] Search
- [ ] Syntax highlighting



## Ember 0.4 — IDE Features

- [ ] Build runner
- [ ] Git
- [ ] LSP
- [ ] Diagnostics
- [ ] Hover
- [ ] Go to definition
- [ ] Autocomplete



## Ember 0.5 — Full Development Environment

- [ ] Integrated terminal
- [ ] Markdown preview
- [ ] Image viewer
- [ ] Configurable keybindings
- [ ] Themes



## Final Goal

- [ ] Open Ember
- [ ] Open the Ember repository
- [ ] Edit Ember's Zig source
- [ ] Build Ember from inside Ember
- [ ] Read compiler errors inside Ember
- [ ] Navigate with ZLS
- [ ] Use Ember as the main editor for developing Ember itself