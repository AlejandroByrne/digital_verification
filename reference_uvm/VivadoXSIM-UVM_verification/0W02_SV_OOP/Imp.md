`$fatal` : SystemVerilog system task $fatal is used to flag a severe run-time exception condition, print an error message, 
        and immediately terminate the simulation.
        It is a crucial debugging and error-handling tool in verification testbenches. 
        
`$fatal [ ( error_code [ , message_string { , message_argument } ] ) ] ;`

* `error_code`: An optional integer value passed to the $finish system task to set the level of diagnostic information reported.
* `message_string` and `message_argument`: Optional user-defined message and arguments, similar to those used with the $display system task. 

