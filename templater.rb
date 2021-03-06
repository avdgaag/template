require 'rubygems'
require 'rspec/autorun'
require 'ostruct'

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

  module IterationInterpolation
    PATTERN = SectionInterpolation::PATTERN

    def render
      super.gsub(PATTERN) do |m|
        render_iterable(fetch($1), $2) || m
      end
    end

    private

    def render_iterable(iterable, templ)
      return unless iterable.respond_to?(:each)
      return '' if iterable.empty?

      iterable.each.inject('') do |output, element|
        output + Templater.new(templ, element).render
      end
    end
  end

  def initialize(template, data = {})
    @template, @data = template, data
    extend VariableInterpolation,
      SectionInterpolation,
      IterationInterpolation
  end

  def render
    template
  end

  private

  def fetch(key, default = nil)
    if data.respond_to? :fetch
      data.fetch key.to_sym, default
    elsif data.respond_to? key
      data.send key
    else
      default
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

    context 'when using an object as key/pair' do
      let(:data) { OpenStruct.new(name: 'Eric') }

      it 'uses a method call to replace keys with values' do
        should == 'Hello, Eric! Your  is Eric.'
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

  context 'with iteration' do
    let(:template) { 'Members: {{#members}}{{name}} {{/members}}' }

    context 'and missing key' do
      it 'omits the entire section' do
        should == 'Members: '
      end
    end

    context 'and non-iterable value' do
      let(:data) { { members: false, name: 'Foo' } }

      it 'omits the entire section' do
        should == 'Members: '
      end
    end

    context 'and filled iterable value' do
      let(:data) { { members: [{ name: 'John' }, { name: 'Graham' }], name: 'Terry' } }

      it 'shows the section for each element' do
        should == 'Members: John Graham '
      end
    end

    context 'and empty iterable value' do
      let(:data) { { members: [], name: 'Terry' } }

      it 'shows the section for each element' do
        should == 'Members: '
      end
    end
  end
end
