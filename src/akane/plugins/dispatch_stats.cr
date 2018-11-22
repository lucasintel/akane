module Akane
  class DispatchStats
    include Discord::Plugin

    @[Discord::Handler(event: :dispatch)]
    def on_dispatch(dispatch)
      name, _ = dispatch
      DB.insert_dispatch(name)
    end
  end
end
