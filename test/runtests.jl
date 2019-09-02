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
  @testset "Testing push back and front of lists" begin
    local b::DoubleEnded.MutableList = DoubleEnded.fromList(list(1))
    DoubleEnded.push_list_front(b, list(1,2,3))
    @test llist(1, 2, 3, 1) == b.front
    DoubleEnded.push_list_back(b, list(6, 7, 8, 9))
    @test b.back.head == 9
    @test length(b) == 8
    @test b.front.head == 1
    local tmpMLst = DoubleEnded.empty()
    @test tmpMLst isa DoubleEnded.MutableList
  end
end

@testset "Operations tests" begin
  dLst2::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3))
  @test DoubleEnded.pop_front(dLst2) == 1
  @test dLst2.length == 2
  @test llist(2,3) == dLst2.front
  @test llist(3) == dLst2.back
  @testset "Test mapping operations" begin
    local refLst::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3,4))
    local lambda = (X, Y) -> X * Y
    #= Try  to mutate the refLst =#
    DoubleEnded.mapNoCopy_1(refLst, lambda, 2)
    @test refLst.front == llist(2, 4, 6, 8)
    @test length(refLst.front) == 4
    local refLst2::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3,4))
    local lambda2 = (X, Y) -> (X * Y, X * Y)
    local foldRes = DoubleEnded.mapFoldNoCopy(refLst2, lambda2, 1)
    @test refLst2.front == llist(1, 2, 6, 24)
    @test foldRes == 24
  end
end

@testset "teardown tests" begin
  local dLst2::DoubleEnded.MutableList = DoubleEnded.fromList(list(1,2,3))
  local ilst::ImmutableList.List = DoubleEnded.toListAndClear(dLst2)
  @test list(1,2,3) == ilst
end

end #DoubleEnded tests
