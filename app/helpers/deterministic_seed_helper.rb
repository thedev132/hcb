# frozen_string_literal: true

module DeterministicSeedHelper

  def use_seeded_random(seed = Random.new_seed)
    @seeded_random = Random.new(seed)
  end

  # You can use this just like you'd use `rand` or `random`
  # d_rand => 0.123456789
  # d_rand(2) => 1
  # d_rand(4..10) => 8
  def d_rand(*args)
    @seeded_random.rand(*args)
  end

  # You can use this just like you'd use `sample` on an array
  # [1,2,3].d_sample => 2
  # [1,2,3].d_sample(2) => [1,3]
  def d_sample(args)
    Array.instance_method(:sample).bind(args).call(random: @seeded_random)
  end
end
