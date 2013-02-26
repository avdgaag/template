require 'rubygems'
require 'rspec/autorun'

class Templater
  attr_reader :template, :data

  module VariableInterpolation
    PATTERN = /\{\{(\w+)\}\}/

    def render
      super.gsub(PATTERN) { fetch $1 }
    end
  end

  module SectionInterpolation
    PATTERN = /\{\{#(\w+)\}\}(.*?)\{\{\/\1\}\}/

    def render
      super.gsub(PATTERN) { $2 if fetch $1 }
    end
  end

  def initialize(template, data = {})
    @template, @data = template, data
    extend VariableInterpolation, SectionInterpolation
  end

  def render
    template
  end

  private

  def fetch(key, default = nil)
    data.fetch key.to_sym, default
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

  context 'with sections' do
    let(:template) { 'You are logged in{{#admin}} and an administrator{{/admin}}.' }

    context 'and missing key' do
      it 'omits the entire section' do
        should == 'You are logged in.'
      end
    end

    context 'and truthy value' do
      let(:data) { { admin: true } }

      it 'shows the section' do
        should == 'You are logged in and an administrator.'
      end
    end

    context 'and falsy value' do
      let(:data) { { admin: false } }

      it 'omits the entire section' do
        should == 'You are logged in.'
      end
    end
  end
end
