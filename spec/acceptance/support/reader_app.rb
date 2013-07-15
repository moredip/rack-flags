require 'sinatra/base'

class ReaderApp < Sinatra::Base
  enable :raise_errors
  disable :show_exceptions 

  get "/" do
    flags = RackFlags.for_env(env)

    output = []
    if flags.on?( :foo )
      output << "foo is on"
    else
      output << "foo is off"
    end

    if flags.on?( :bar )
      output << "bar is on"
    else
      output << "bar is off"
    end

    output.join("; ")
  end
end
