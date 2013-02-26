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

  context 'with a single placeholder' do
    let(:template) { 'Hello, {{name}}!' }

    context 'when the key is present' do
      let(:data) { { name: 'Eric' } }

      it 'replaces the placeholder with they key value' do
        should == 'Hello, Eric!'
      end
    end

    context 'when the key is not present' do
      it 'omits the placeholder' do
        should == 'Hello, !'
      end
    end
  end

  context 'with multiple placeholders' do
    let(:template) { 'Hello, {{name}}! Your {{attr}} is {{name}}.' }
    let(:data) { { name: 'Graham', attr: 'name' } }

    it 'replaces all placeholders with their corresponding values' do
      should == 'Hello, Graham! Your name is Graham.'
    end
  end
end
