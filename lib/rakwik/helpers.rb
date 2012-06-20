module Rakwik
  module Helpers
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
      base.class_eval do
        after_filter :set_action_name
      end
    end
    
    module ClassMethods
      def rakwik
        @rakwik ||= {}
      end
      
      def action_name(var_name)
        rakwik[:action_name] = var_name
      end
    end
    
    module InstanceMethods
      def set_action_name
        return if self.class.rakwik[:action_name].nil?
        request.env['rakwik.action_name'] = instance_variable_get("@#{self.class.rakwik[:action_name]}")
      end
    end
  end
end
