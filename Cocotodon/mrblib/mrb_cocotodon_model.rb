module Cocotodon
    class World < Diva::Model
        include Plugin::World::TraditionalBehavior::World
        register :cocotodon_world, name: 'Cocotodon World'
        
        def uri
            Diva::URI.new("cocotodon://world/")
        end
    end
    
    class User < Diva::Model
        register :cocotodon_user, name: 'Cocotodon User'
        
        field.uri :url, required: true
        field.string :acct, required: true
        field.string :username
        
        def idname
            self[:acct]
        end
        
        def uri
            url
        end
    end
    
    class Message < Diva::Model
        include Plugin::World::TraditionalBehavior::Message
        register :cocotodon_message, name: 'Cocodoton Message'
        
        field.string :id, required: true
        field.uri :uri, required: true
        field.uri :url, required: true
        field.string :content, required: true
        field.string :spoiler_text
        field.string :visibility, required: true
        field.has :account, Cocotodon::User, required: true
        
        def description
            @description ||= self[:spoiler_text].empty? ? self[:content] : "#{self[:spoiler_text]}\n---\n#{self[:content]}"
        end
        
        def user
            account
        end
        
        def perma_link
            url
        end
    end
end
