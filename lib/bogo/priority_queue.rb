require 'bogo'

module Bogo
  # Specialized priority based queue
  # @note does not allow duplicate objects to be queued
  class PriorityQueue

    # Create a new priority queue
    #
    # @return [self]
    def initialize(*args)
      @lock = Mutex.new
      @queue = Hash.new
      @block_costs = 0
      @reverse_sort = args.include?(:highscore)
    end

    # Push new item to the queue
    #
    # @param item [Object]
    # @param cost [Float]
    # @yield provide cost via proc
    # @return [self]
    def push(item, cost=nil, &block)
      lock.synchronize do
        if(queue[item])
          raise ArgumentError.new "Item already exists in queue. Items must be unique! (#{item})"
        end
        unless(cost || block_given?)
          raise ArgumentError.new 'Cost must be provided as parameter or block!'
        end
        @block_costs += 1 if cost.nil?
        queue[item] = cost || block
        sort!
      end
      self
    end

    # @return [Object, NilClass] item or nil if empty
    def pop
      lock.synchronize do
        sort! if @block_costs > 0
        item, score = queue.first
        @block_costs -= 1 if score.respond_to?(:call)
        queue.delete(item)
        item
      end
    end

    # @return [Integer] current size of queue
    def size
      lock.synchronize do
        queue.size
      end
    end

    def empty?
      size == 0
    end

    # Sort the queue based on cost
    def sort!
      queue.replace(
        Hash[
          queue.sort do |x,y|
            x,y = y,x if @reverse_score
            (x.last.respond_to?(:call) ? x.last.call : x.last).to_f <=>
              (y.last.respond_to?(:call) ? y.last.call : y.last).to_f
          end
        ]
      )
    end

    protected

    attr_reader :queue, :lock

  end

end