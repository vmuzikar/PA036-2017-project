#!/usr/local/bin/tclsh8.6
if [catch {package require Pgtcl} ] { error "Failed to load Pgtcl - Postgres Library Error" }
#EDITABLE OPTIONS##################################################
set total_iterations $TOTAL_ITERATIONS ;# Number of transactions before logging off
set RAISEERROR "false" ;# Exit script on PostgreSQL (true or false)
set KEYANDTHINK "false" ;# Time for user thinking and keying (true or false)
set rampup 2;  # Rampup time in minutes before first Transaction Count is taken
set duration 5;  # Duration in minutes before second Transaction Count is taken
set mode "Local" ;# HammerDB operational mode
set VACUUM "false" ;# Perform checkpoint and vacuuum when complete (true or false)
set DRITA_SNAPSHOTS "false";#Take DRITA Snapshots
set ora_compatible "false" ;#Postgres Plus Oracle Compatible Schema
set host "$HOST" ;# Address of the server hosting PostgreSQL
set port "$PORT" ;# Port of the PostgreSQL server
set superuser "postgres" ;# Superuser privilege user
set superuser_password "postgres" ;# Password for Superuser
set default_database "postgres" ;# Default Database for Superuser
set user "$DB_USER" ;# PostgreSQL user
set password "$DB_USER_PASS" ;# Password for the PostgreSQL user
set db "$DB_NAME" ;# Database containing the TPC Schema
#EDITABLE OPTIONS##################################################
#CHECK THREAD STATUS
proc chk_thread {} {
	set chk [package provide Thread]
	if {[string length $chk]} {
	    return "TRUE"
	    } else {
	    return "FALSE"
	}
    }
if { [ chk_thread ] eq "FALSE" } {
error "PostgreSQL Timed Test Script must be run in Thread Enabled Interpreter"
}

proc ConnectToPostgres { host port user password dbname } {
global tcl_platform
if {[catch {set lda [pg_connect -conninfo [list host = $host port = $port user = $user password = $password dbname = $dbname ]]} message]} {
set lda "Failed" ; puts $message
error $message
 } else {
if {$tcl_platform(platform) == "windows"} {
#Workaround for Bug #95 where first connection fails on Windows
catch {pg_disconnect $lda}
set lda [pg_connect -conninfo [list host = $host port = $port user = $user password = $password dbname = $dbname ]]
        }
pg_notice_handler $lda puts
set result [ pg_exec $lda "set CLIENT_MIN_MESSAGES TO 'ERROR'" ]
pg_result $result -clear
        }
return $lda
}

set mythread [thread::id]
set allthreads [split [thread::names]]
set totalvirtualusers [expr [llength $allthreads] - 1]
set myposition [expr $totalvirtualusers - [lsearch -exact $allthreads $mythread]]
if {![catch {set timeout [tsv::get application timeout]}]} {
if { $timeout eq 0 } { 
set totalvirtualusers [ expr $totalvirtualusers - 1 ] 
set myposition [ expr $myposition - 1 ]
	}
}
switch $myposition {
1 { 
if { $mode eq "Local" || $mode eq "Master" } {
if { ($DRITA_SNAPSHOTS eq "true") || ($VACUUM eq "true") } {
set lda [ ConnectToPostgres $host $port $superuser $superuser_password $default_database ]
if { $lda eq "Failed" } {
error "error, the database connection to $host could not be established"
 	} 
}
set lda1 [ ConnectToPostgres $host $port $user $password $db ]
if { $lda1 eq "Failed" } {
error "error, the database connection to $host could not be established"
 	} 
set ramptime 0
puts "Beginning rampup time of $rampup minutes"
set rampup [ expr $rampup*60000 ]
while {$ramptime != $rampup} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set ramptime [ expr $ramptime+6000 ]
if { ![ expr {$ramptime % 60000} ] } {
puts "Rampup [ expr $ramptime / 60000 ] minutes complete ..."
	}
}
if { [ tsv::get application abort ] } { break }
if { $DRITA_SNAPSHOTS eq "true" } {
puts "Rampup complete, Taking start DRITA snapshot."
set result [pg_exec $lda "select * from edbsnap()" ]
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "DRITA Snapshot Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
pg_select $lda {select edb_id,snap_tm from edb$snap order by edb_id desc limit 1} snap_arr {
set firstsnap $snap_arr(edb_id)
set first_snaptime $snap_arr(snap_tm)
	}
puts "Start Snapshot $firstsnap taken at $first_snaptime"
	}
   } else {
puts "Rampup complete, Taking start Transaction Count."
	}
pg_select $lda1 "select sum(xact_commit + xact_rollback) from pg_stat_database" tx_arr {
set start_trans $tx_arr(sum)
	}
pg_select $lda1 "select sum(d_next_o_id) from district" o_id_arr {
set start_nopm $o_id_arr(sum)
	}
puts "Timing test period of $duration in minutes"
set testtime 0
set durmin $duration
set duration [ expr $duration*60000 ]
while {$testtime != $duration} {
if { [ tsv::get application abort ] } { break } else { after 6000 }
set testtime [ expr $testtime+6000 ]
if { ![ expr {$testtime % 60000} ] } {
puts -nonewline  "[ expr $testtime / 60000 ]  ...,"
	}
}
if { [ tsv::get application abort ] } { break }
if { $DRITA_SNAPSHOTS eq "true" } {
puts "Test complete, Taking end DRITA snapshot."
set result [pg_exec $lda "select * from edbsnap()" ]
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Snapshot Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
pg_select $lda {select edb_id,snap_tm from edb$snap order by edb_id desc limit 1} snap_arr  {
set endsnap $snap_arr(edb_id)
set end_snaptime $snap_arr(snap_tm)
	}
puts "End Snapshot $endsnap taken at $end_snaptime"
puts "Test complete: view DRITA report from SNAPID $firstsnap to $endsnap"
	}
   } else {
puts "Test complete, Taking end Transaction Count."
	}
pg_select $lda1 "select sum(xact_commit + xact_rollback) from pg_stat_database" tx_arr {
set end_trans $tx_arr(sum)
	}
pg_select $lda1 "select sum(d_next_o_id) from district" o_id_arr {
set end_nopm $o_id_arr(sum)
	}
set tpm [ expr {($end_trans - $start_trans)/$durmin} ]
set nopm [ expr {($end_nopm - $start_nopm)/$durmin} ]
puts "$totalvirtualusers Virtual Users configured"
puts "TEST RESULT : System achieved $tpm PostgreSQL TPM at $nopm NOPM"
tsv::set application abort 1
if { $mode eq "Master" } { eval [subst {thread::send -async $MASTER { remote_command ed_kill_vusers }}] }
if { $VACUUM } {
	set RAISEERROR "true"
puts "Checkpoint and Vacuum"
set result [pg_exec $lda "checkpoint" ]
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Checkpoint Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
set result [pg_exec $lda "vacuum" ]
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Vacuum Error set RAISEERROR for Details"
		}
	} else {
puts "Checkpoint and Vacuum Complete"
pg_result $result -clear
	}
}
if { ($DRITA_SNAPSHOTS eq "true") || ($VACUUM eq "true") } {
pg_disconnect $lda
	}
pg_disconnect $lda1
		} else {
puts "Operating in Slave Mode, No Snapshots taken..."
		}
	}
default {
#RANDOM NUMBER
proc RandomNumber {m M} {return [expr {int($m+rand()*($M+1-$m))}]}
#NURand function
proc NURand { iConst x y C } {return [ expr {((([RandomNumber 0 $iConst] | [RandomNumber $x $y]) + $C) % ($y - $x + 1)) + $x }]}
#RANDOM NAME
proc randname { num } {
array set namearr { 0 BAR 1 OUGHT 2 ABLE 3 PRI 4 PRES 5 ESE 6 ANTI 7 CALLY 8 ATION 9 EING }
set name [ concat $namearr([ expr {( $num / 100 ) % 10 }])$namearr([ expr {( $num / 10 ) % 10 }])$namearr([ expr {( $num / 1 ) % 10 }]) ]
return $name
}
#TIMESTAMP
proc gettimestamp { } {
set tstamp [ clock format [ clock seconds ] -format %Y%m%d%H%M%S ]
return $tstamp
}
#KEYING TIME
proc keytime { keying } {
after [ expr {$keying * 1000} ]
return
}
#THINK TIME
proc thinktime { thinking } {
set thinkingtime [ expr {abs(round(log(rand()) * $thinking))} ]
after [ expr {$thinkingtime * 1000} ]
return
}
#NEW ORDER
proc neword { lda no_w_id w_id_input RAISEERROR ora_compatible } {
#2.4.1.2 select district id randomly from home warehouse where d_w_id = d_id
set no_d_id [ RandomNumber 1 10 ]
#2.4.1.2 Customer id randomly selected where c_d_id = d_id and c_w_id = w_id
set no_c_id [ RandomNumber 1 3000 ]
#2.4.1.3 Items in the order randomly selected from 5 to 15
set ol_cnt [ RandomNumber 5 15 ]
#2.4.1.6 order entry date O_ENTRY_D generated by SUT
set date [ gettimestamp ]
if { $ora_compatible eq "true" } {
set result [pg_exec $lda "exec neword($no_w_id,$w_id_input,$no_d_id,$no_c_id,$ol_cnt,0,TO_TIMESTAMP($date,'YYYYMMDDHH24MISS'))" ]
} else {
set result [pg_exec $lda "select neword($no_w_id,$w_id_input,$no_d_id,$no_c_id,$ol_cnt,0)" ]
}
if {[pg_result $result -status] != "PGRES_TUPLES_OK"} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "New Order Procedure Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
}
#PAYMENT
proc payment { lda p_w_id w_id_input RAISEERROR ora_compatible } {
#2.5.1.1 The home warehouse id remains the same for each terminal
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set p_d_id [ RandomNumber 1 10 ]
#2.5.1.2 customer selected 60% of time by name and 40% of time by number
set x [ RandomNumber 1 100 ]
set y [ RandomNumber 1 100 ]
if { $x <= 85 } {
set p_c_d_id $p_d_id
set p_c_w_id $p_w_id
} else {
#use a remote warehouse
set p_c_d_id [ RandomNumber 1 10 ]
set p_c_w_id [ RandomNumber 1 $w_id_input ]
while { ($p_c_w_id == $p_w_id) && ($w_id_input != 1) } {
set p_c_w_id [ RandomNumber 1  $w_id_input ]
	}
}
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set p_c_id [ RandomNumber 1 3000 ]
if { $y <= 60 } {
#use customer name
#C_LAST is generated
set byname 1
 } else {
#use customer number
set byname 0
set name {}
 }
#2.5.1.3 random amount from 1 to 5000
set p_h_amount [ RandomNumber 1 5000 ]
#2.5.1.4 date selected from SUT
set h_date [ gettimestamp ]
#2.5.2.1 Payment Transaction
#change following to correct values
if { $ora_compatible eq "true" } {
set result [pg_exec $lda "exec payment($p_w_id,$p_d_id,$p_c_w_id,$p_c_d_id,$p_c_id,$byname,$p_h_amount,'$name','0',0,TO_TIMESTAMP($h_date,'YYYYMMDDHH24MISS'))" ]
} else {
set result [pg_exec $lda "select payment($p_w_id,$p_d_id,$p_c_w_id,$p_c_d_id,$p_c_id,$byname,$p_h_amount,'$name','0',0)" ]
}
if {[pg_result $result -status] != "PGRES_TUPLES_OK"} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Payment Procedure Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
}
#ORDER_STATUS
proc ostat { lda w_id RAISEERROR ora_compatible } {
#2.5.1.1 select district id randomly from home warehouse where d_w_id = d_id
set d_id [ RandomNumber 1 10 ]
set nrnd [ NURand 255 0 999 123 ]
set name [ randname $nrnd ]
set c_id [ RandomNumber 1 3000 ]
set y [ RandomNumber 1 100 ]
if { $y <= 60 } {
set byname 1
 } else {
set byname 0
set name {}
}
if { $ora_compatible eq "true" } {
set result [pg_exec $lda "exec ostat($w_id,$d_id,$c_id,$byname,'$name')" ]
} else {
set result [pg_exec $lda "select * from ostat($w_id,$d_id,$c_id,$byname,'$name') as (ol_i_id NUMERIC,  ol_supply_w_id NUMERIC, ol_quantity NUMERIC, ol_amount NUMERIC, ol_delivery_d TIMESTAMP,  out_os_c_id INTEGER, out_os_c_last VARCHAR, os_c_first VARCHAR, os_c_middle VARCHAR, os_c_balance NUMERIC, os_o_id INTEGER, os_entdate TIMESTAMP, os_o_carrier_id INTEGER)" ]
}
if {[pg_result $result -status] != "PGRES_TUPLES_OK"} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Order Status Procedure Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
}
#DELIVERY
proc delivery { lda w_id RAISEERROR ora_compatible } {
set carrier_id [ RandomNumber 1 10 ]
set date [ gettimestamp ]
if { $ora_compatible eq "true" } {
set result [pg_exec $lda "exec delivery($w_id,$carrier_id,TO_TIMESTAMP($date,'YYYYMMDDHH24MISS'))" ]
} else {
set result [pg_exec $lda "select delivery($w_id,$carrier_id)" ]
}
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Delivery Procedure Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
}
#STOCK LEVEL
proc slev { lda w_id stock_level_d_id RAISEERROR ora_compatible } {
set threshold [ RandomNumber 10 20 ]
if { $ora_compatible eq "true" } {
set result [pg_exec $lda "exec slev($w_id,$stock_level_d_id,$threshold)" ]
} else {
set result [pg_exec $lda "select slev($w_id,$stock_level_d_id,$threshold)" ]
}
if {[pg_result $result -status] ni {"PGRES_TUPLES_OK" "PGRES_COMMAND_OK"}} {
if { $RAISEERROR } {
error "[pg_result $result -error]"
		} else {
puts "Stock Level Procedure Error set RAISEERROR for Details"
		}
	} else {
pg_result $result -clear
	}
}
#RUN TPC-C
set lda [ ConnectToPostgres $host $port $user $password $db ]
if { $lda eq "Failed" } {
error "error, the database connection to $host could not be established"
 } else {
if { $ora_compatible eq "true" } {
set result [ pg_exec $lda "exec dbms_output.disable" ]
pg_result $result -clear
	}
 }
pg_select $lda "select max(w_id) from warehouse" w_id_input_arr {
set w_id_input $w_id_input_arr(max)
	}
#2.4.1.1 set warehouse_id stays constant for a given terminal
set w_id  [ RandomNumber 1 $w_id_input ]  
pg_select $lda "select max(d_id) from district" d_id_input_arr {
set d_id_input $d_id_input_arr(max)
}
set stock_level_d_id  [ RandomNumber 1 $d_id_input ]  
puts "Processing $total_iterations transactions without output suppressed..."
set abchk 1; set abchk_mx 1024; set hi_t [ expr {pow([ lindex [ time {if {  [ tsv::get application abort ]  } { break }} ] 0 ],2)}]
for {set it 0} {$it < $total_iterations} {incr it} {
if { [expr {$it % $abchk}] eq 0 } { if { [ time {if {  [ tsv::get application abort ]  } { break }} ] > $hi_t }  {  set  abchk [ expr {min(($abchk * 2), $abchk_mx)}]; set hi_t [ expr {$hi_t * 2} ] } }
set choice [ RandomNumber 1 23 ]
if {$choice <= 10} {
if { $KEYANDTHINK } { keytime 18 }
neword $lda $w_id $w_id_input $RAISEERROR $ora_compatible
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 20} {
if { $KEYANDTHINK } { keytime 3 }
payment $lda $w_id $w_id_input $RAISEERROR $ora_compatible
if { $KEYANDTHINK } { thinktime 12 }
} elseif {$choice <= 21} {
if { $KEYANDTHINK } { keytime 2 }
delivery $lda $w_id $RAISEERROR $ora_compatible
if { $KEYANDTHINK } { thinktime 10 }
} elseif {$choice <= 22} {
if { $KEYANDTHINK } { keytime 2 }
slev $lda $w_id $stock_level_d_id $RAISEERROR $ora_compatible
if { $KEYANDTHINK } { thinktime 5 }
} elseif {$choice <= 23} {
if { $KEYANDTHINK } { keytime 2 }
ostat $lda $w_id $RAISEERROR $ora_compatible
if { $KEYANDTHINK } { thinktime 5 }
	}
}
pg_disconnect $lda
		}
	}
    

