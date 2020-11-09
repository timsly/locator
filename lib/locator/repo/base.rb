# frozen_string_literal: true

module Locator
  module Repo
    class Base
      extend Forwardable
      include Enumerable

      def_delegators :scope, :size, :[], :last, :empty?

      def initialize(entry_class)
        @entry_class = entry_class
      end

      def scope
        @scope ||= build
      end

      def build
        load.map { |data| @entry_class.new(data) }
      end

      def load
        raise NotImplementedError
      end

      def reload
        @scope = nil

        self
      end

      def each(&block)
        return enum_for unless block

        scope.each(&block)
      end

      # Instead of returning an array return a copy of the repo with modified scope
      %i[find_all select sort_by].each do |method|
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{method}(*args)
            new(super)
          end
        CODE
      end

      private

      def new(val = nil, &block)
        raise ArgumentError, 'Either block or argument is required' unless val || block

        current_scope = @scope
        @scope = block ? block.call : val
        dup
      ensure
        @scope = current_scope
      end
    end
  end
end
