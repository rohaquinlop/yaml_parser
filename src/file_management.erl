-module(file_management).
-export([read_lines/1]).

read_lines(FileName) ->
    {ok, Data} = file:read_file(FileName),
    try
        binary:split(Data, [<<"\n">>], [global])
    after
        file:close(Data)
    end.
