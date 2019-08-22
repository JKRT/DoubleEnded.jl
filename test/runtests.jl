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
  @test dLst2.front == 1
  @test dLst2.back == 3
  @test dLst2.length == 3
end

@testset "Operations tests" begin

end

@testset "teardown tests" begin

end

end #DoubleEnded tests
