using Test
import DoubleEnded
import DataStructures
using ImmutableList

include("../src/linkedListAliases.jl")

@testset "DoubleEnded tests" begin
  @testset "Creation tests" begin
  #= Creating an empty list =#
  lst1::List = nil
  dLst1::DoubleEnded.MutableList = DoubleEnded.fromList(lst1)
  @test dLst1.length == 0
  @test dLst1.front == lnil()
  @test dLst1.back == lnil()
  #= Create a list of 3 elements =#
  lst2 = list(1, 2, 3)
  dLst2 = DoubleEnded.fromList(lst2)
  @test dLst2.front.head == 1
  @test dLst2.back.head == 3
  @test dLst2.length == 3
end

@testset "Operations tests" begin
  dLst2::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3))
  @test DoubleEnded.pop_front(dLst2) == 1
  @test dLst2.length == 2
  @test llist(2,3) == dLst2.front
  @test llist(3) == dLst2.back
end

@testset "teardown tests" begin
  local dLst2::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3))
  local ilst::ImmutableList.List = DoubleEnded.toListAndClear(dLst2)
  @test list(1,2,3) == ilst
end

end #DoubleEnded tests
