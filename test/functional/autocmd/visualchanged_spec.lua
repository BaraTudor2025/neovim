local helpers = require('test.functional.helpers')(after_each)

local clear = helpers.clear
local eq = helpers.eq
local meths = helpers.meths
local eval = helpers.eval
local source = helpers.source
local feed = helpers.feed
local insert = helpers.insert

describe('VisualChanged', function()
  before_each(clear)
  before_each(function()
    insert[[
      Hello
      Hello
      Hello]]
    feed("gg0")
    source[[
      let g:visual_count = 0
      au VisualChanged * let g:event = copy(v:event)
      au VisualChanged * let g:visual_count += 1
    ]]
  end)

  local function event()
    return meths.get_var("event")
  end

  local function count()
    return meths.get_var("visual_count")
  end

  it("fires when visual mode changes or starts", function ()
    feed "v"
    eq(1, count())

    feed "iw"
    eq(2, count())

    feed "V"
    eq(3, count())

    feed "<c-v>"
    eq(4, count())
    
    feed "v"
    eq(5, count())

    feed "<esc>v"
    eq(6, count())

    feed "<esc>V"
    eq(7, count())

    feed "<esc><c-v>"
    eq(8, count())
  end)
  
  it("fires when visual area changes", function()
    feed "v"
    eq(1, count())
    eq({
      start_line = 1,
      end_line = 1,
      start_col = 1,
      end_col = 1,
    }, event())

    feed "iw"
    eq(2, count())
    eq({
      start_line = 1,
      end_line = 1,
      start_col = 1,
      end_col = 5,
    }, event())

    feed "Vj"
    eq(4, count())
    eq({
      start_line = 1,
      end_line = 2,
      start_col = 1,
      end_col = eval("v:maxcol"),
    }, event())

    feed "<esc>Vj"
    eq(6, count())
    eq({
      start_line = 2,
      end_line = 3,
      start_col = 1,
      end_col = eval("v:maxcol"),
    }, event())

    feed "<esc>gg<c-v>ejh"
    eq(10, count())
    eq({
      start_line = 1,
      end_line = 2,
      start_col = 1,
      end_col = 4,
    }, event())
  end)

  it("doesn't fire when cursor moves without changing visual area", function()
    feed "viw"
    eq(2, count())
    feed "oOoO"
    eq(2, count())

    feed "V"
    eq(3, count())
    feed "$hh0ll$h"
    eq(3, count())

    feed "j"
    eq(4, count())
    feed "oOoOo"
    eq(4, count())

    feed "<esc>gg<c-v>$j"
    eq(7, count())
    feed "oOoOo"
    eq(7, count())
  end)

  it("works with gv", function()
    feed "vjl"
    eq(3, count())
    local old_event = event()

    feed "<esc>Ggv"
    eq(4, count())
    eq(old_event, event())
  end)

  it("v:event has the same range as '< '> registers", function()
    source [[au VisualChanged * let g:start = getpos("'<") | let g:end = getpos("'>")]]
    source [[au VisualChanged * let g:cur = getpos(".") | let g:vis = getpos("v")]]
    local regs = function ()
      local s = meths.get_var("start")
      local e = meths.get_var("end")
      return {
        start_line = s[2],
        start_col = s[3],
        end_line = e[2],
        end_col = e[3]
      }
    end
    local cursors = function ()
      local s = meths.get_var("vis")
      local e = meths.get_var("cur")
      return {
        start_line = s[2],
        start_col = s[3],
        end_line = e[2],
        end_col = e[3]
      }
    end

    feed "v"
    eq(regs(), event())
    --eq(cursors(), event())

    feed "iw"
    eq(regs(), event())
    --eq(cursors(), event())

    feed "Vjhh"
    eq(regs(), event())
    --eq(cursors(), event())

    feed "<esc>Vj"
    eq(regs(), event())
    --eq(cursors(), event())

    feed "<esc>gg<c-v>ejh"
    eq(regs(), event())
    --eq(cursors(), event())
  end)

end)
