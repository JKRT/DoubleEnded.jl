#= /*
* This file is part of OpenModelica.
*
* Copyright (c) 1998-2026, Open Source Modelica Consortium (OSMC),
* c/o Linköpings universitet, Department of Computer and Information Science,
* SE-58183 Linköping, Sweden.
*
* All rights reserved.
*
* THIS PROGRAM IS PROVIDED UNDER THE TERMS OF AGPL VERSION 3 LICENSE OR
* THIS OSMC PUBLIC LICENSE (OSMC-PL) VERSION 1.8.
* ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES
* RECIPIENT'S ACCEPTANCE OF THE OSMC PUBLIC LICENSE OR THE GNU AGPL VERSION 3,
* ACCORDING TO RECIPIENTS CHOICE.
*
* The OpenModelica software and the OSMC (Open Source Modelica Consortium)
* Public License (OSMC-PL) are obtained from OSMC, either from the above
* address, from the URLs:
* http://www.openmodelica.org or
* https://github.com/OpenModelica/ or
* http://www.ida.liu.se/projects/OpenModelica,
* and in the OpenModelica distribution.
*
* GNU AGPL version 3 is obtained from:
* https://www.gnu.org/licenses/licenses.html#GPL
*
* This program is distributed WITHOUT ANY WARRANTY; without
* even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
* IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS OF OSMC-PL.
*
* See the full OSMC Public License conditions for more details.
*
*/ =#

"""
  Author: John Tinnerholm

  Mirrors the MetaModelica record:

      uniontype MutableList<T>
        record LIST
          Mutable<Integer> length;
          Mutable<list<T>> front;
          Mutable<list<T>> back;
        end LIST;
      end MutableList;

  `front` and `back` hold actual `ImmutableList` cons cells. `back` points to
  the LAST cell, so `push_back` is O(1) via `listSetRest` (in-place tail
  update of the last cell). `nil` is the empty value, shared with the rest
  of the OM.jl runtime.
"""
module DoubleEnded

using ExportAll
using ImmutableList
using ImmutableList.Unsafe: listSetFirst, listSetRest

"""
    MutableList{T}

A mutable list with elements of type `T`. Fields: `length`, `front` (first
cell), `back` (last cell). `front` and `back` are `Nil` when the list is empty.
"""
mutable struct MutableList{T}
  length::Int
  front::Union{Nil, Cons{T}}
  back::Union{Nil, Cons{T}}
end

MutableList{T}() where {T} = MutableList{T}(0, nil, nil)

"""
    new(first)

Creates a `MutableList{typeof(first)}` with the one element `first`.
"""
function new(first::T) where {T}
  local cell = Cons{T}(first, nil)
  MutableList{T}(1, cell, cell)
end

"""
    fromList(lst)

Converts the ImmutableList `lst` into a `MutableList`, in O(n). The result
holds new cells: it does not share cells with `lst`. `fromList(nil)` returns
a `MutableList{Any}`.
"""
function fromList(::Nil)
  MutableList{Any}()
end

function fromList(lst::Cons{T}) where {T}
  local mlst = MutableList{T}()
  for e in lst
    push_back(mlst, e)
  end
  mlst
end

"""
    empty(dummy)
    empty()

Creates an empty `MutableList`. `empty(dummy)` has element type
`typeof(dummy)`; `empty()` has element type `Any`. Not exported: call it as
`DoubleEnded.empty`.
"""
function empty(dummy::T) where {T}
  MutableList{T}()
end

empty() = MutableList{Any}()

"""
    length(delst)

Returns the number of elements of `delst`, in O(1).
"""
Base.length(delst::MutableList) = delst.length

"""
    pop_front(delst)

Removes and returns the first element of `delst`. Throws `ArgumentError` if
`delst` is empty.
"""
function pop_front(delst::MutableList{T}) where {T}
  delst.front isa Nil && throw(ArgumentError("pop_front on empty MutableList"))
  local cell = delst.front::Cons{T}
  local popped = cell.head
  delst.front = cell.tail
  if delst.front isa Nil
    delst.back = nil
  end
  delst.length -= 1
  popped
end

"""
    currentBackCell(delst)

Returns the last cell of `delst`, or `nil` if `delst` is empty.
"""
currentBackCell(delst::MutableList) = delst.back

"""
    push_front(delst, elt)

Prepends `elt` (converted to the element type) to `delst`, in O(1). Returns
`delst`.
"""
function push_front(delst::MutableList{T}, elt) where {T}
  local cell = Cons{T}(convert(T, elt), delst.front)
  delst.front = cell
  if delst.back isa Nil
    delst.back = cell
  end
  delst.length += 1
  delst
end

"""
    push_list_front(delst, lst)

Prepends the elements of the ImmutableList `lst` to `delst`, in order, in
O(n). Returns `delst`.
"""
function push_list_front(delst::MutableList, lst::List)
  for e in listReverse(lst)
    push_front(delst, e)
  end
  delst
end

"""
    push_back(delst, elt)

Appends `elt` (converted to the element type) to `delst`, in O(1). Sets the
tail of the previous back cell to the new cell. Returns `delst`.
"""
function push_back(delst::MutableList{T}, elt) where {T}
  local newCell = Cons{T}(convert(T, elt), nil)
  if delst.back isa Nil
    delst.front = newCell
  else
    listSetRest(delst.back::Cons{T}, newCell)
  end
  delst.back = newCell
  delst.length += 1
  delst
end

"""
    push_list_back(delst, lst)

Appends the elements of the ImmutableList `lst` to `delst`, in order, in
O(n). Returns `delst`.
"""
function push_list_back(delst::MutableList, lst::List)
  for e in lst
    push_back(delst, e)
  end
  delst
end

"""
    toListAndClear(delst; prependToList = nil)

Returns the elements of `delst` as an ImmutableList, followed by
`prependToList`, and clears `delst`. The splice is O(1): the tail of the back
cell is set to `prependToList`.
"""
function toListAndClear(delst::MutableList{T};
                        prependToList::Union{Nil, Cons{T}} = nil) where {T}
  if delst.length == 0
    clear(delst)
    return prependToList
  end
  if !(prependToList isa Nil)
    listSetRest(delst.back::Cons{T}, prependToList)
  end
  local result = delst.front
  clear(delst)
  result
end

"""
    toListNoCopyNoClear(delst)

Returns the first cell of `delst` as an ImmutableList, without copying or
clearing `delst`. If `delst` is non-empty, in-place changes of the cells
(`push_back`, `mapNoCopy_1`, `mapFoldNoCopy`) show through the returned list.
`push_front`, `pop_front` and `clear` do not. If `delst` is empty, the result
is `nil` and stays `nil`.
"""
function toListNoCopyNoClear(delst::MutableList)
  delst.front
end

"""
    clear(delst)

Removes all elements of `delst`. Returns `delst`.
"""
function clear(delst::MutableList)
  delst.front = nil
  delst.back = nil
  delst.length = 0
  delst
end

"""
    mapNoCopy_1(delst, inMapFunc, inArg1)

Replaces each element `e` of `delst` by `inMapFunc(e, inArg1)`, in place.
Returns `delst`.
"""
function mapNoCopy_1(delst::MutableList{T}, inMapFunc::Function, inArg1) where {T}
  local cur = delst.front
  while !(cur isa Nil)
    local cell = cur::Cons{T}
    listSetFirst(cell, convert(T, inMapFunc(cell.head, inArg1)))
    cur = cell.tail
  end
  delst
end

"""
    mapFoldNoCopy(delst, inMapFunc, arg)

Folds `delst` in place. Starts with the accumulator `arg`. For each element
`e`, `(newElt, newAcc) = inMapFunc(e, acc)` replaces `e` by `newElt` and sets
the accumulator to `newAcc`. Returns the final accumulator.
"""
function mapFoldNoCopy(delst::MutableList{T}, inMapFunc::Function, arg) where {T}
  local cur = delst.front
  local argo = arg
  while !(cur isa Nil)
    local cell = cur::Cons{T}
    local newHead, newAcc = inMapFunc(cell.head, argo)
    listSetFirst(cell, convert(T, newHead))
    argo = newAcc
    cur = cell.tail
  end
  argo
end

"""
    iterate(delst)

Iterates over the elements of `delst`, front to back. Used by `for x in delst`
and `collect(delst)`.
"""
Base.iterate(delst::MutableList) = _iter(delst.front)
Base.iterate(::MutableList, state) = _iter(state)
Base.eltype(::Type{MutableList{T}}) where {T} = T
Base.IteratorSize(::Type{<:MutableList}) = Base.HasLength()

@inline _iter(::Nil) = nothing
@inline _iter(cell::Cons) = (cell.head, cell.tail)

@exportAll

end #= DoubleEnded =#
