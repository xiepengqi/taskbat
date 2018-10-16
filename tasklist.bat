@echo off&setlocal enabledelayedexpansion	
::this is my task manager bat script
mode con cols=200 lines=800
:reboot

set home=%~dp0
set main=tasklist_bat.main
set tmp=tasklist_bat.tmp
set history=tasklist_bat.history
set lateststatus=tasklist_bat.lateststatus
set targetlist=tasklist_bat.targetlist

set mainfile=%home%%main%
set tmpfile=%home%%tmp%
set historyfile=%home%%history%
set lateststatusfile=%home%%lateststatus%
set targetlistfile=%home%%targetlist%

set suffix_batext=.batext
set currid=0
set stringtype_flag=d
set run_split_key=@

call :usage

if not exist %mainfile% (
	echo [ID]	    [CONTENT]> %mainfile%
)

if not exist %historyfile% (
	type nul> %historyfile%
	call :genlateststatuslist
)

if not exist %targetlistfile% (
	type nul> %targetlistfile%
)

call :setcurrid
echo setcurrid 		done
call :genlateststatuslist
echo genlateststatuslist 	done
call :genbatext
echo genbatext 		done

set usercommand=%1 %2 %3 %4 %5 %6 %7 %8 %9
if not "%usercommand%" == "        " (
	set onlineFlag=true
	goto :oneline
)

:cycle
if "%onlineFlag%" == "true" (
	goto :break
)

set /p usercommand="please type your operate:"

:oneline

call :splitusercommand

if "%usercommand%" == "add" (
	set /a currid=!currid!+1
	if "!args_1!" == "" (
		set /p content="please enter content:"
	) else (
		set content=!args_1! !args_2! !args_3! !args_4! !args_5! !args_6! !args_7! !args_8! !args_9!
	)
	echo !currid!	    !content!>>%mainfile%
	echo !currid!	    add   	     [%date% %time%]	    !content!>>%historyfile%
	call :genlateststatuslist
) else if  "%usercommand%" == "del" (
	if "!args_1!" == "" (
		set /p id="please enter id:"
	) else (
		set id=!args_1!
	)
	call :stringtype !id!
	if "!stringtype_flag!" == "d" (
		call :deleteline !id!
	)
	if "!stringtype_flag!" == "w" (
		echo invalid args
	)
) else if "%usercommand%" == "upd" (
	if "!args_1!" == "" (
		set /p id="please enter id:"
	) else (
		set id=!args_1!
	)
	if "!args_2!" == "" (
		set /p updateline_input_newcontent="please enter new content:"
	) else (
		set updateline_input_newcontent=!args_2! !args_3! !args_4! !args_5! !args_6! !args_7! !args_8! !args_9!
	)
	call :stringtype !id!
	if "!stringtype_flag!" == "d" (
		call :updateline !id! 
	)
	if "!stringtype_flag!" == "w" (
		echo invalid args
	)
) else if "%usercommand%" == "sm" ( 
	if not "!args_1!" == "" (
		call :stringtype !args_1!
		if "!stringtype_flag!" == "d" (
			call :restore !args_1!
			type %mainfile%
		)
		if "!stringtype_flag!" == "w" (
			call :querystatus !args_1!
		)
	) else (
		type %mainfile%
	)
) else if "%usercommand%" == "fn" ( 
	if "!args_1!" == "" (
		set /p id="please enter id:"
	) else (
		set id=!args_1!
	)
	call :stringtype !id!
	if "!stringtype_flag!" == "d" (
		call :finishline !id!
	)
	if "!stringtype_flag!" == "w" (
		echo invalid args
	)
) else if "%usercommand%" == "hd" ( 
	if "!args_1!" == "" (
		set /p id="please enter id:"
	) else (
		set id=!args_1!
	)
	call :stringtype !id!
	if "!stringtype_flag!" == "d" (
		call :holdline !id!
	)
	if "!stringtype_flag!" == "w" (
		echo invalid args
	)
) else if "%usercommand%" == "cls" ( 
	cls
) else if "%usercommand%" == "sh" ( 
	call :showhistory
) else if "%usercommand%" == "q" ( 
	goto :break
) else if "%usercommand%" == "rebuildtasklist" ( 
	del %mainfile% && pushd %home% && ren %history% %history%.bak.%date:~4,2%%date:~7,2%%date:~10,4%%time:~0,2%%time:~3,2%%time:~6,2%%time:~9,2% && popd
	cls
	goto :reboot
) else if "%usercommand%" == "run" (
	call :run "run"
) else if "%usercommand%" == "r" (
	call :run "r"
) else (
	call :usage
) 

goto :cycle
:break


goto :functionend
:usage
	set usage_notice=notice^^!: in tasklist_bat.targetlist file, %run_split_key% is key in targetlist, and need replace ^^! by "^^^!"
	echo Usage: 1,add[content] 2,del[id] 3,upd[id][content] 4,sm[key] 5,fn[id] 6,hd[id] 7,cls 8,sh[key1][key2] 9,q 10,rebuildtasklist
	echo Super: 1,run[key1][key2] 2,r [key1][key2] !usage_notice!
goto :eof

:run
	set run_count=0
	set run_mod=%1
	
	type %targetlistfile%> %tmpfile%
	for /l %%a in (1,1,9) do if not "!args_%%a!" == "" (
		findstr/i "!args_%%a!" %tmpfile%> %tmpfile%.tmp
		del %tmpfile%> nul
		move %tmpfile%.tmp %tmpfile%> nul 
	)

	for /f "delims=%run_split_key% tokens=1,*" %%i in (%tmpfile%) do if not "%%j" == "" (
		set /a run_count+=1
		set run_head_!run_count!=%%i
		set run_content_!run_count!=%%j
		
		echo !run_count!,%%i
	)
	
	if !run_count! geq 1 (
		if !run_mod! == "r" (
			set run_choose=1
		) else (
			set /p run_choose="your choose:"
		)
		
		for /f "tokens=1,* usebackq" %%a in ('!run_choose!') do (
			call :stringtype %%a
			if "!stringtype_flag!" == "d" (
		    	for /l %%h in (1,1,!run_count!) do (
		    		if %%a equ %%h (
						set run_curr_extbat_name=!run_head_%%h!
						set run_curr_extbat_file=%home%!run_curr_extbat_name!%suffix_batext%
		    			for /f "tokens=1,* usebackq" %%o in ('!run_content_%%h!') do (	
							if exist "!run_curr_extbat_file!" (
								if not "%%p" == "" (
									type "!run_curr_extbat_file!">  %tmpfile%
									if not "%%o" == "" (
										set run_file=%tmpfile%.%%o
									) else (
										set run_file=%tmpfile%
									)
									move %tmpfile% !run_file! > nul
									%%p !run_file! %%b
								)	
							) else (
								!run_content_%%h! %%b
							)	 
		    			)
		    		)
		    	)
		    )
		    if "!stringtype_flag!" == "w" (
		    	echo invalid args
		    )
		)
	) else (
		echo no target found
	)
goto :eof

:genbatext
if exist %home%*%suffix_batext% (
	del %home%*%suffix_batext%
)
set batext_file=default
for /f "delims=%run_split_key% tokens=1,*" %%i in (%targetlistfile%) do (
	if not "%%j" == "" (
		set batext_file=%home%%%i%suffix_batext%
	) else (
		echo %%i>> !batext_file!
	)
)
goto :eof

:deleteline
	echo [ID]	    [CONTENT]> %tmpfile%
	for /f "skip=1 tokens=1,*" %%i in (%mainfile%) do (
		if not "%%i" == "%1" (
			echo %%i	    %%j>> %tmpfile%
		) else (
			echo %1	    delete	     [%date% %time%]	    %%j>>%historyfile%
			call :genlateststatuslist
		)
	)
	del %mainfile% && pushd %home% && ren %tmp% %main% && popd
goto :eof

:restore
	set tomain=default
	set tohistory=default
	for /f "tokens=1,2,3,4,5,*" %%i in (%historyfile%) do (
		if %1 equ %%i (
			if "%%j" == "delete" (
				set tomain=%%i	    %%n
				set tohistory=%1	    restore	     [%date% %time%]	    %%n
			)
			if "%%j" == "finish" (
				set tomain=%%i	    %%n
				set tohistory=%1	    restore	     [%date% %time%]	    %%n
			)
			if "%%j" == "hold" (
				set tomain=%%i	    %%n
				set tohistory=%1	    restore	     [%date% %time%]	    %%n
			)
			if "%%j" == "restore" (
				set tomain=default
				set tohistory=default
			)
		)
	)
	if not "!tomain!" == "default" (
		echo !tomain!>> %mainfile%
	)
	if not "!tohistory!" == "default" (
		echo !tohistory!>> %historyfile%
		call :genlateststatuslist
	)
goto :eof

:updateline
	echo [ID]	    [CONTENT]> %tmpfile%
	for /f "skip=1 tokens=1,*" %%i in (%mainfile%) do (
		if not "%%i" == "%1" (
			echo %%i	    %%j>> %tmpfile%
		) else (
			echo %%i	    !updateline_input_newcontent!>> %tmpfile%
			echo %1	    update	     [%date% %time%]	    !updateline_input_newcontent!>> %historyfile%
			call :genlateststatuslist
		)
	)
	del %mainfile% && pushd %home% && ren %tmp% %main% && popd
goto :eof

:finishline
	echo [ID]	    [CONTENT]> %tmpfile%
	for /f "skip=1 tokens=1,*" %%i in (%mainfile%) do (
		if not "%%i" == "%1" (
			echo %%i	    %%j>> %tmpfile%
		) else (
			echo %1	    finish	     [%date% %time%]	    %%j>>%historyfile%
			call :genlateststatuslist
		)
	)
	del %mainfile% && pushd %home% && ren %tmp% %main% && popd
goto :eof

:holdline
	echo [ID]	    [CONTENT]> %tmpfile%
	for /f "skip=1 tokens=1,*" %%i in (%mainfile%) do (
		if not "%%i" == "%1" (
			echo %%i	    %%j>> %tmpfile%
		) else (
			echo %1	    hold  	     [%date% %time%]	    %%j>>%historyfile%
			call :genlateststatuslist
		)
	)
	del %mainfile% && pushd %home% && ren %tmp% %main% && popd
goto :eof

:setcurrid
	for /f "skip=1 tokens=1" %%i in (%historyfile%) do (
		if  %%i gtr !currid! (
			set currid=%%i
		)
	)
goto :eof

:showhistory
	echo [ID]	    [ACTION]	     [DATE]	    			    [CONTENT]
	type %historyfile%> %tmpfile%
			
	for /l %%a in (1,1,9) do if "!args_%%a!" neq "" (
		call :stringtype !args_%%a!
		if "!stringtype_flag!" == "d" (
			set stringtype_flag=w
			( 
				for /f "tokens=1,*" %%i in (!tmpfile!) do (
					if "!args_%%a!" == "%%i" ( 
						echo %%i	    %%j 
						set stringtype_flag=d
					)
				) 
			)> %tmpfile%.tmp		
		)
		if "!stringtype_flag!" == "w" (
			findstr/i "!args_%%a!" %tmpfile%> %tmpfile%.tmp
		)
		
		del %tmpfile%> nul
		move %tmpfile%.tmp %tmpfile%> nul
	)

	type %tmpfile%
goto :eof

:querystatus
	echo [ID]	    [STATUS]	     [DATE]	    			    [CONTENT]
	set querystatus_tmp=%1
	set querystatus_key=default
	if "!querystatus_tmp!" == "u" (
		set querystatus_key=update
	) else if "!querystatus_tmp!" == "d" (
		set querystatus_key=delete
	) else if "!querystatus_tmp!" == "h" (
		set querystatus_key=hold
	) else if "!querystatus_tmp!" == "f" (
		set querystatus_key=finish
	) else if "!querystatus_tmp!" == "a" (
		set querystatus_key=add
	) else if "!querystatus_tmp!" == "r" (
		set querystatus_key=restore
	)
	if "!querystatus_key!" == "default" (
		type  %lateststatusfile%
	)
	for /f "tokens=1,2,*" %%i in ( %lateststatusfile%) do (
		if "!querystatus_key!" == "%%j" (
			if "!querystatus_key!" == "add" (
				echo %%i	    %%j	             %%k 
			) else (
				echo %%i	    %%j	     %%k 
			)
		)
	)
goto :eof

:genlateststatuslist
	(
		for /l %%a in (1,1,!currid!) do (
			set genlateststatuslist_curr_record=default
			for /f "tokens=1,*" %%i in (%historyfile%) do (
				if "%%a" == "%%i" (
					set genlateststatuslist_curr_record=%%i	    %%j
				)
			)
			if not "!genlateststatuslist_curr_record!" == "default" (
				echo !genlateststatuslist_curr_record!
			)	
		) 
	)> %lateststatusfile%
goto :eof


:stringtype
	set stringtype_begin=0
	set stringtype_step=1
	set stringtype_len=1
	set stringtype_tmpid=%1
	set stringtype_flag=d
	if "!stringtype_tmpid!" == "" (
		goto :eof
	)
	:stringtype_loop
		echo !stringtype_tmpid:~%stringtype_begin%,%stringtype_step%! | findstr "[0-9]"> nul
		if !errorlevel! neq 0 (
			set stringtype_flag=w
			goto :break_stringtype_loop
		)
		if "!stringtype_tmpid:~0,%stringtype_len%!" == "!stringtype_tmpid!" (
			goto :break_stringtype_loop
		)
		set /a stringtype_begin+=1
		set /a stringtype_len+=1
	goto :stringtype_loop
	:break_stringtype_loop
goto :eof

:splitusercommand
	for /f "usebackq tokens=1,2,3,4,5,6,7,8,9,*" %%i in ('!usercommand!') do (
		set usercommand=%%i
		set args_1=%%j
		set args_2=%%k
		set args_3=%%l
		set args_4=%%m
		set args_5=%%n
		set args_6=%%o
		set args_7=%%p
		set args_8=%%q
		set args_9=%%r
	)
goto :eof
:functionend


