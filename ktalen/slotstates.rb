class EventDesc
   attr_accessor :name
   def initialize name
      @name = name
   end
   def prototype
      "#{@name}()"
   end
   def slot
      SLOT prototype
   end
end

class StatefulSlotController < Qt::Object
   EVTYPE_APPINIT = -1
   APPREADY_EVENT = EventDesc.new "appready"
   def initialize *k
      super(*k)
      @@ccs = {}
      @@blocks = {}
      def_event_handler(APPREADY_EVENT.name) { continue EVTYPE_APPINIT }
   end
   def def_event_handler name, &block
      @@blocks[name] = block
      self.class.module_eval %{
         slots "#{name}()"
         def #{name}
            @@blocks["#{name}"].call
         end
      }
      EventDesc.new name
   end
   def init_app app
      callcc { |cont|
         @@ccs[EVTYPE_APPINIT] = cont
         Qt::Timer::singleShot 0, self, APPREADY_EVENT.slot
         app.exec
      }
      @@ccs.delete EVTYPE_APPINIT
   end
   def wait_on_event evtype
      ret = callcc { |cont|
         @@ccs[evtype] = cont
         Qt::Application::eventLoop.exec
      }
      @@ccs.delete evtype
      ret
   end
   def continue evtype, *k
      @@ccs[evtype].call(*k) if @@ccs.has_key? evtype
   end
end
