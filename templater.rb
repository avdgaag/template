require 'rubygems'
require 'rspec/autorun'

class Templater
  attr_reader :template, :data

  def initialize(template, data = {})
    @template, @data = template, data
  end

  def render
    template.gsub(/\{\{([^}]+)\}\}/) do
      data.fetch($1.to_sym, '')
    end
  end
end

describe Templater do
  subject    { described_class.new(template, data).render }
  let(:data) { { } }

  context 'with a regular string' do
    let(:template) { 'Hello, world!' }

    it 'returns the string unaltered' do
      should == 'Hello, world!'
    end
  end

  context 'with placeholders' do
    let(:template) { 'Hello, {{name}}! Your {{attr}} is {{name}}.' }

    context 'when keys are present' do
      let(:data) { { name: 'Graham', attr: 'name' } }

      it 'replaces all placeholders with their corresponding values' do
        should == 'Hello, Graham! Your name is Graham.'
      end
    end

    context 'when a key is not present' do
      let(:data) { { name: 'Graham' } }

      it 'omits the placeholder' do
        should == 'Hello, Graham! Your  is Graham.'
      end
    end
  end
end
