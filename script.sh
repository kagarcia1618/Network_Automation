#!/usr/bin/expect
 
set timeout 20
set user [lindex $argv 0]
set password [lindex $argv 1]
set prompt "#"
set time [timestamp -format %d%m%Y]
 
;# -- main activity

proc dostuff { currenthost} {

        set fd [open ./commandlist r]
        set commands [read -nonewline $fd]
        close $fd

        ;# do something with currenthost

        foreach command [split $commands "\n" ] {

                send -- "$command\r"
                expect -- "$currenthost#"

        }
        send -- "exit\r\r"

}
 
;# -- start of task
 
set fd [open ./hostlist r]
set hosts [read -nonewline $fd]
close $fd

 
foreach host [split $hosts "\n" ] {
 
    set data [split $host ":"]
 
    spawn /usr/bin/ssh $user@[lindex $data 1]

    log_file -noappend ./logs/[lindex $data 0]_[lindex $data 1]_$time.cfg
 
    while (1) {
        expect {
 
                        "no)? " {
                                send -- "yes\r"

                                expect {

                                        "*assword" {
                                                send -- "$password\r"
                                        }

                                        "Permission denied, please try again." {
                                                break
                                        }
                                }
                        }

                        "*assword:" {
                                send -- "$password\r"

                                expect {

                                        "Permission denied, please try again." {
                                                break
                                        }

                                        "$prompt" {
                                                dostuff [lindex $data 0]
                                                break
                                        }
                                }
                        }

                        "$prompt" {
                                dostuff [lindex $data 0]
                                break
                        }

                        "*refused"  {
                                send -- "Access Issue!\r"
                                break
                        }

                        "*host" {
                                send -- "Access Issue!\r"
                                break
                        }

                        "*[lindex $data 1]" {
                                send -- "Access Issue!\r"
                                break
                        }


                        "Permission denied, please try again."  {
                                send -- "Access Issue!\r"
                                break
                        }
                }
    }

   log_file

}
expect eof
