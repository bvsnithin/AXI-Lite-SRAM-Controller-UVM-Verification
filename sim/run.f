// Simulation options
-uvm
+access+rwc
-timescale 1ns/1ps

// Include paths for UVM TB files
+incdir+../tb/transaction
+incdir+../tb/agent
+incdir+../tb/env
+incdir+../tb/sequence
+incdir+../tb/test

// Source files
-f file_list.f

// UVM options
+UVM_VERBOSITY=UVM_MEDIUM
