require "rakwik/tracker"

module Rakwik
  # Taken from http://www.hiringthing.com/2011/11/04/eventmachine-with-rails.html
  # Thanks Joshua!
  def self.start
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
      # for passenger, we need to avoid orphaned threads
        if forked && EM.reactor_running?
          EM.stop
        end
        Thread.new {
          EM.run do
            puts "=> EventMachine started"
          end
        }
        die_gracefully_on_signal
      end
    else
      # faciliates debugging
      Thread.abort_on_exception = true
      # just spawn a thread and start it up
      Thread.new {
        EM.run do
          puts "=> EventMachine started"
        end
      } unless defined?(Thin)
      # Thin is built on EventMachine, doesn't need this thread
    end
  end
end

Rakwik.start
