ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

if Gem.win_platform?
  module Signal
    class << self
      alias_method :original_trap, :trap
      def trap(sig, *args, &block)
        sig_str = sig.to_s.upcase rescue ""
        if sig_str == "QUIT" || sig_str == "SIGQUIT"
          nil
        else
          original_trap(sig, *args, &block)
        end
      rescue ArgumentError => e
        if e.message.include?("unsupported signal")
          nil
        else
          raise
        end
      end
    end
  end

  module Kernel
    alias_method :original_trap, :trap
    def trap(sig, *args, &block)
      sig_str = sig.to_s.upcase rescue ""
      if sig_str == "QUIT" || sig_str == "SIGQUIT"
        nil
      else
        original_trap(sig, *args, &block)
      end
    rescue ArgumentError => e
      if e.message.include?("unsupported signal")
        nil
      else
        raise
      end
    end
    module_function :trap
  end
end
