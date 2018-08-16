using Test

include("../src/ImageHist.jl")

@testset "ImageHist Tests" begin
  @testset "Constructors" begin
    thing = ImageHist([2, 3, 1, 3, 2])
    @test_throws ErrorException thing = ImageHist([2, 3, 1, 3, 2], 1, 10)
    @test thing.s_idx == 1
    @test thing.sz == 11
  end # constructors end
  @testset "Basic array functions" begin
    tst_hist = ImageHist([2, 3, 1, 3, 2], 2)
    @test length(tst_hist) == 5
    @test eltype(tst_hist) == Int
    @test_throws BoundsError th = getindex(tst_hist, 1)
    @test firstindex(tst_hist) == 2
    @test lastindex(tst_hist) == 6
  end # array end
end # imagehist tests
