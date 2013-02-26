require 'rubygems'
require 'rspec/autorun'

class Templater
  attr_reader :template

  def initialize(template)
    @template = template
  end

  def render
    template
  end
end

describe Templater do
  subject { described_class.new(template).render }

  context 'with a regular string' do
    let(:template) { 'Hello, world!' }

    it 'returns the string unaltered' do
      should == 'Hello, world!'
    end
  end
end
