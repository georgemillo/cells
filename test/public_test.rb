require 'test_helper'

class PublicTest < MiniTest::Spec
  class SongCell < Cell::ViewModel
    def initialize(*args)
      @initialize_args = *args
    end
    attr_reader :initialize_args

    def show
      initialize_args.inspect
    end

    def detail
      "* #{initialize_args}"
    end
  end

  # ViewModel.cell returns the cell instance.
  it { Cell::ViewModel.cell(PublicTest::SongCell).must_be_instance_of SongCell }

  # ViewModel.cell passes options to cell.
  it { Cell::ViewModel.cell(PublicTest::SongCell, Object, genre: "Metal").initialize_args.must_equal [Object, {genre:"Metal"}] }

  # ViewModel.cell(collection: []) renders cells.
  it { Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).to_s.must_equal '[Object, {}][Module, {}]' }

  # DISCUSS: should cell.() be the default?
  # ViewModel.cell(collection: []) renders cells with custom join.
  it do
    Gem::Deprecate::skip_during do
      Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).join('<br/>') do |cell|
          cell.()
      end.must_equal '[Object, {}]<br/>[Module, {}]'
    end
  end

  # ViewModel.cell(collection: []) passes generic options to cell.
  it { Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module], genre: 'Metal', context: { ready: true }).to_s.must_equal "[Object, {:genre=>\"Metal\", :context=>{:ready=>true}}][Module, {:genre=>\"Metal\", :context=>{:ready=>true}}]" }

  # ViewModel.cell(collection: []).() invokes #show.
  it { Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).().must_equal '[Object, {}][Module, {}]' }

  # ViewModel.cell(collection: []).(:detail) invokes #detail instead of #show.
  it { Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).(:detail).must_equal '* [Object, {}]* [Module, {}]' }

  # #cell(collection: [], genre: "Fusion").() doesn't change options hash.
  it do
    Cell::ViewModel.cell(PublicTest::SongCell, options = { genre: "Fusion", collection: [Object] }).()
    options.to_s.must_equal "{:genre=>\"Fusion\", :collection=>[Object]}"
  end

  # it do
  #   content = ""
  #   Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).each_with_index do |cell, i|
  #     content += (i == 1 ? cell.(:detail) : cell.())
  #   end

  #   content.must_equal '[Object, {}]* [Module, {}]'
  # end

  # cell(collection: []).join captures return value and joins it for you.
  it do
    Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).join do |cell, i|
      i == 1 ? cell.(:detail) : cell.()
    end.must_equal '[Object, {}]* [Module, {}]'
  end

  # cell(collection: []).join("<") captures return value and joins it for you with join.
  it do
    Cell::ViewModel.cell(PublicTest::SongCell, collection: [Object, Module]).join(">") do |cell, i|
      i == 1 ? cell.(:detail) : cell.()
    end.must_equal '[Object, {}]>* [Module, {}]'
  end

  # 'join' can be used without a block:
  it do
    Cell::ViewModel.cell(
      PublicTest::SongCell, collection: [Object, Module]
    ).join('---').must_equal('[Object, {}]---[Module, {}]')
  end
end
