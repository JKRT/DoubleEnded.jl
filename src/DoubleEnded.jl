"""
Author: John Tinnerholm
  This package provides a DoubleEnded list with various utility methods
"""
module DoubleEnded

import DataStructures

using ExportAll
using ImmutableList
using DataStructures: LinkedList
include("linkedListAliases.jl")

mutable struct MutableList{T}
  length::Int
  front::LinkedList{T}
  back::LinkedList{T}
end

function new(first::T) where {T}
  lst = DataStructures.list(first)
  MutableList(1, lst, lst)
end

function fromList(lst::List{T})  where {T}
  #= Rethink this =#
  if lst isa Nil
    return MutableList(0, llist(), llist())
  end
  #= Otherwise we loop =#
  local linkedLst::LinkedList = lnil()
  local cntr::Int = 0
  for i in lst
    linkedLst = lcons(i, linkedLst)
    cntr += 1
  end
  local linkedLst = reverse(linkedLst)
  local newFront = linkedLst
  local cntr2::Int = 0
  local backList::LinkedList = linkedLst
  for i in 1:cntr - 1
    backList = backList.tail
  end
  MutableList(cntr, newFront, backList)
end

function empty(dummy::T)  where {T}
  MutableList(0, llist(), llist())
end

function length(delst::MutableList{T})  where {T}
  delst.length
end

function pop_front(delst::MutableList{T})  where {T}
  if length==1 then
    delst.front = llist()
    delst.back = llist()
    delst.length = 0
  end
  popped_elem = delst.front.head
  delst.front = delst.front.tail
  delst.length -= 1
  popped_elem
end

function currentBackCell(delst::MutableList{T})  where {T}
  delst.back
end

function push_front(delst::MutableList{T}, elt::T)  where {T}
  local currentHead = delst.front.head
  delst.front.tail = cons(elt, cons(currentHead, delst.front.tail))
end

function push_list_front(delst::MutableList{T}, lst::List{T})  where {T}
  local mutableList::LinkedList = list(lst...)

end

function push_back(delst::MutableList{T}, elt::T)  where {T}
  delst.back = cons(elt, nil())
end

function push_list_back(delst::MutableList{T}, lst::List{T})  where {T}
  #=TODO=#
end

function toListAndClear(delst::MutableList{T}, prependToList::List{T} = nil)  where {T}
  local linkedLst::LinkedList = lnil()
  local pl = prependToList
  for i in reverse(delst.front)
    pl = i <| pl
  end
  #Clear delst
  delst.length = 0
  delst.front = llist()
  delst.back = llist()
  pl
end

#= Returns the working list, which may be changed later on! =#
function toListNoCopyNoClear(delst::MutableList{T})  where {T}
  local res::List{T} = nil
  for i in lst:-1:1
    res = i <| res
  end
end

function clear(delst::MutableList{T})  where {T}
  delst.back = lnil()
  delst.front = lnil()
  delst.length = 0
end

function mapNoCopy_1(delst::MutableList{T}, inMapFunc::Function, inArg1::ArgT1)  where {T, ArgT1}
  local lst = delst.front
  for i in lst
    inMapFunc(i, inArg1)
  end
end

function mapFoldNoCopy(delst::MutableList{T}, inMapFunc::Function, arg::ArgT1)  where {T, ArgT1}
  println("mapFoldNoCopy not yet implemented")
  fail()
end

@exportAll

end #= DoubleEnded =#
