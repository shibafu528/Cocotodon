module Cocotodon
    module SettingsCompat
        def self.included(klass)
            klass.extend Methods
        end

        module Methods
            def settings(name, &proc)
                add_event_filter(:defined_settings) do |tabs|
                    [tabs.melt << [name, proc, self.name]]
                end
            end
        end

        include Methods
    end
end

Plugin.include Cocotodon::SettingsCompat
