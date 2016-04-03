#! /usr/bin/ruby

require 'minitest/autorun'
require 'minitest/benchmark'

class TestCoreMethods < Minitest::Benchmark
  def setup
    @arrays = ( 1 .. 11_000 ).map { |n| [ 42 ] * n }
  end

  # Override self.bench_range or default range is [1, 10, 100, 1_000, 10_000]
  def bench_size
    assert_performance_linear 0.99 do |n| ( [ 0 ] * n ).reduce :+ end
    assert_performance_constant 0.99 do |n| 42.times { 42 } end
    # assert_performance_linear 0.99 do |n| @arrays[ n ].size end
    assert_performance_constant 0.99 do |n| @arrays[ n ].size end
    # TODO: For some reason, assert_performance_constant doesn't fail even if
    # I artificially introduce eg. quadratic algorithm. All the while, the
    # line assert_performance_linear does fail if uncommented (since the perf.
    # here is constant).
    # TODO: In other words, I'm not very experienced in performance testing yet.
  end
end
