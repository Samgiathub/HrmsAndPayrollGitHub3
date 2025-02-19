


-- created by rohit for send inout mail with customized Column.
-- Created Date :- 12052017
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Inout_Reminder_Consolidated]
	@cmp_id_Pass Numeric(18,0) = 1,
	@CC_Email Nvarchar(max) = '',
	@period Nvarchar(500) = 'Yesterday', -- Period :- 'Weekly' , 'Monthly' , 'Today' , 'Yesterday' 
	@To Nvarchar(500) =  'Manager', -- 'Branch Manager','Employee','HOD','HR','Manager'
	@cc Nvarchar(500) = '', -- 'HR' , 'Manager'
	@Wise Nvarchar(500) = 'Branch Wise', -- 'Branch Wise','Department Wise','Manager Wise','Shift Wise','Employee Wise'
	@Format Nvarchar(max) = '',
	@Subject_para Nvarchar(500)='In Out Mail',
	@column nvarchar(max)='' 
AS 
BEGIN   

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      Declare @From_Date as Datetime
      Declare @To_Date as Datetime
      SET @DATE = CAST(GETDATE() AS varchar(11))
      
      if @period = 'Monthly'
      BEGIN 
		set @To_Date = cast(DATEADD(dd,-(DAY(Getdate())),getdate()) as varchar(max))
		set @From_Date = cast(DATEADD(dd,-(DAY(@To_Date)-1),@To_Date) as varchar(max))
      END
      ELSE IF @period = 'Weekly'
      Begin
		  set @To_Date = cast(DATEADD(day,
				   -2 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7,
				   GETDATE()) as varchar)
		  set @From_Date = cast(DATEADD(dd, -(DATEPART(dw, @To_Date)-1), @To_Date) as varchar)
		   
      end
      ELSE IF @period = 'Yesterday'
      Begin
       set @To_Date =  cast((Getdate()-1) as varchar(max))
       set @From_Date =  cast((Getdate()-1) as varchar(max))
      end
      ELSE IF @period = 'Today'
      Begin
		   set @To_Date =  cast((Getdate()) as varchar(max))
		   set @From_Date =  cast((Getdate()) as varchar(max))
      end
      
	IF OBJECT_ID('tempdb..#Temp_inout') IS NOT NULL 
		 BEGIN
			   DROP TABLE #Temp_inout
		 END
	   
	CREATE table #Temp_inout(
	emp_id Numeric,
	for_Date Datetime,
	Dept_id varchar(max),
	Grd_ID varchar(200),
	Type_ID varchar(max),
	Desig_ID Varchar(max),
	Shift_ID varchar(max),
	In_Time varchar(max),
	Out_Time varchar(max),
	Duration varchar(max),
	Duration_sec varchar(max),
	Late_In varchar(max),
	Late_Out varchar(max),
	Early_In varchar(max),
	Early_Out varchar(max),
	Leave varchar(max),
	Shift_Sec varchar(max),
	Shift_Dur varchar(max),
	Total_work varchar(max),
	Less_Work varchar(max),
	More_Work varchar(max),
	Reason varchar(max),
	Other_Reason varchar(300) null, 
	AB_LEAVE varchar(max),
	Late_In_Sec varchar(max),
	Late_In_count varchar(max),
	Early_Out_sec varchar(max),
	Early_Out_Count varchar(max),
	Total_Less_work_Sec varchar(max),
	Shift_St_Datetime varchar(max),
	Shift_en_Datetime varchar(max),
	Working_Sec_AfterShift varchar(max),
	Working_AfterShift_Count varchar(max),
	Leave_Reason varchar(max),
	Inout_Reason varchar(max),
	SysDate varchar(max),
	Total_Work_Sec varchar(max),
	Late_Out_Sec varchar(max),
	Early_In_sec varchar(max),
	Total_More_work_Sec varchar(max),
	Is_OT_Applicable varchar(max),
	Monthly_Deficit_Adjust_OT_Hrs varchar(max),
	Late_Comm_sec varchar(max),
	Branch_Id varchar(max),
	P_Days varchar(max),
	Emp_full_Name varchar(max),
	Alpha_Emp_Code varchar(max),
	Emp_Code varchar(max),
	Grd_Name varchar(max),
	Shift_name varchar(max),
	dept_name varchar(max),
	Type_Name varchar(max),
	Desig_Name varchar(max),
	CMP_NAME varchar(max),
	CMP_ADDRESS varchar(max),
	P_From_date varchar(max),
	P_To_Date varchar(max),
	Shift_Start_Time varchar(max),
	Shift_End_Time varchar(max),
	Actual_In_Time varchar(max),
	Actual_Out_Time varchar(max),
	On_Date varchar(max),
	manager_Id varchar(10),
	Branch_Name Varchar(max)
	) 
       
	set @from_date = REPLACE(CONVERT(VARCHAR(11),@from_date,106), ' ','-')
	set @To_Date = REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-')

	Insert Into #Temp_inout 
	exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@PBranch_ID='0',@Report_call = 'Inout_Mail'      


	Declare @Consolidate_Email_id	nvarchar(4000)
	Declare @Consolidate_Id as numeric
	Declare @Consolidate_Name as varchar(255)
	Declare @Consolidate_cmp_id as numeric(18,0)
	
	if @Wise = 'Branch Wise'
	begin
		declare Cur_Consolidate cursor for                    
		 select Distinct Branch_id from #Temp_inout order by Branch_id
	end	
	Else if @Wise = 'Department Wise'
	begin
		declare Cur_Consolidate cursor for                    
		 select Distinct Dept_id from #Temp_inout order by Dept_id
	end	
	Else if @Wise = 'Manager Wise'
	begin
		declare Cur_Consolidate cursor for                    
		 select Distinct TI.manager_Id from #Temp_inout TI  order by manager_Id
	end	
	Else if @Wise = 'Shift Wise'
	begin
		declare Cur_Consolidate cursor for                    
		 select Distinct Shift_ID from #Temp_inout order by Shift_id
	end	
	Else if @Wise = 'Employee Wise'
	begin
		declare Cur_Consolidate cursor for                    
		 select Distinct Emp_id from #Temp_inout order by Emp_id
	end	
	open Cur_Consolidate
	fetch next from Cur_Consolidate into @Consolidate_Id
	while @@fetch_status = 0                    
		begin     
		
			set @Consolidate_Email_id = null
			set @Consolidate_Name = Null	
			set @Consolidate_cmp_id = NULL
			
				   -- 'Branch Manager','Employee','HOD','HR','Manager'
				
					IF (@to ='Branch Manager')
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id = Work_Email, @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=cmp_id  from T0080_EMP_MASTER  WITH (NOLOCK)
						where emp_id in 
						(select TOP 1 emp_id
						FROM T0095_MANAGERS E WITH (NOLOCK) Where E.Branch_ID = @Consolidate_Id and E.Effective_Date <= getdate() order by E.Effective_Date desc)
					END
					Else If (@to ='Employee')
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id = Work_Email, @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=cmp_id  from T0080_EMP_MASTER WITH (NOLOCK) 
						where emp_id = @Consolidate_Id 
					END
					Else IF(@to ='HOD')
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id = Work_Email, @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=cmp_id  from T0080_EMP_MASTER  WITH (NOLOCK)
						where emp_id in 
						(select TOP 1 emp_id
						FROM T0095_Department_Manager E WITH (NOLOCK) Where E.dept_id = @Consolidate_Id and E.Effective_Date <= getdate() order by E.Effective_Date desc)
					END
					Else IF(@to ='HR' and @Wise= 'Branch Wise' )
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id =  email_id , @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=L.cmp_id 
						from T0011_LOGIN L WITH (NOLOCK) left Join T0080_EMP_MASTER E WITH (NOLOCK) ON L.Emp_ID=E.Emp_ID where Is_HR=1 
						AND 1= (CASE WHEN @Consolidate_Id IN (select data from dbo.split(Branch_id_multi,',')) then 1 else 0 END) and E.Cmp_ID = @cmp_id_Pass
						
						if isnull(@Consolidate_Email_id,'') =''
						begin
							SELECT  @Consolidate_Email_id = COALESCE(@Consolidate_Email_id + ',','') + email_id , @Consolidate_Name =  COALESCE(Emp_Full_Name + ',','') +  Emp_Full_Name,@Consolidate_cmp_id=L.cmp_id 
							from T0011_LOGIN L WITH (NOLOCK) left Join T0080_EMP_MASTER E WITH (NOLOCK) ON L.Emp_ID=E.Emp_ID where Is_HR=1 and L.Branch_id_multi =0 and E.Cmp_ID = @cmp_id_Pass
						end
						
					END
					Else IF(@to ='HR' and ( @Wise= 'Department Wise' or @Wise = 'Manager Wise' or @Wise = 'Shift Wise' or @Wise = 'Employee Wise' ))
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id =  email_id , @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=L.cmp_id 
						from T0011_LOGIN L WITH (NOLOCK) left Join T0080_EMP_MASTER E WITH (NOLOCK) ON L.Emp_ID=E.Emp_ID where Is_HR=1 and E.Cmp_ID = @cmp_id_Pass
						--AND 1= (CASE WHEN @Consolidate_Id IN (select data from dbo.split(Branch_id_multi,',')) then 1 else 0 END)
						
					END
					Else IF(@to ='Manager' )
					BEGIN 
						SELECT TOP 1 @Consolidate_Email_id =  Work_Email , @Consolidate_Name = Emp_Full_Name,@Consolidate_cmp_id=cmp_id 
						from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Consolidate_Id
						
					END
				
					
			      ---ALTER dynamic template for Employee.				
				  --Declare  @TableHead varchar(max),
					 --  @TableTail varchar(max)   
      --     		  Set @TableHead = '<html><head>' +
						--		  '<style>' +
						--		  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
						--		  '</style>' +
						--		  '</head>' +
						--		  '<body>
						--		  <div style=" font-family:Arial, Helvetica, sans-serif; color:Black;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
						--		  Dear ' + isnull(@Consolidate_Name,'') + ' </div>	<br/>					
								  
						--		  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
						--		  <tr>
						--			 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
						--				<tr>
						--				<td height="9" align="center" valign="middle" ></td>
						--				</tr>
						--			  <tr>
						--				<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;"> Inout Report  for ( from date ' + convert(varchar(15),@From_Date,103) + ' To ' + convert(varchar(15),@to_date,103) +  ') </td>
						--			  </tr>
						--				  <tr>
						--					<td height="4" align="center" valign="middle"></td>
						--				  </tr>
						--				  <tr>
						--					<td height="8" align="center" valign="middle"></td>
						--				  </tr>
						--		  </table>
                                    
						--		  <table border="1" width="1000" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
						--			border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
						--			color: #000000; text-decoration: none; font-weight: normal; text-align: left;
						--			font-size: 12px;">' +
						--				  '<tr border="1">
						--				  <td align=center><span style="font-size:small"><b>Code</b></span></td>' +
						--				  '<td align=center><b><span style="font-size:small">For Date</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Shift In Time</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Shift Out Time</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Shift Duration</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">In Time</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Out Time</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Duration</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Leave/Weekoff</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Deficit</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Surplus</span></b></td>' +
						--				  '<td align=center><b><span style="font-size:small">Remark</span></b></td>'
      --            SET @TableTail = '</table><table><tr><td style="font-size:small">
      --                      Note:- <span style="color:red;font-size:15px;font-weight:bold">*</span> indicate the late coming or Early Going on Date.
      --                    </td>
      --                    </tr> </table></body></html>';                  	
      --            DECLARE @Body AS VARCHAR(MAX)
      --            DECLARE @Body1 AS VARCHAR(MAX)
      --            SET @Body = ( SELECT  
						--		#Temp_inout.alpha_emp_Code  as [TD],
						--		On_Date  as [TD],
						--		Isnull( dbo.F_GET_AMPM(shift_st_datetime),'-') as [TD],
						--		Isnull(dbo.F_GET_AMPM(shift_en_datetime),'-') as [TD],
						--		Isnull(shift_dur,'-') as [TD],
						--		case when isnull(late_in,'-') in ('-','') then Isnull(Actual_In_Time,'-') else cast( Isnull(Actual_In_Time,'-') as varchar(max)) + ' "*"' end  as [TD],
						--		case when Isnull(early_out,'-')in('-','') then isnull(Actual_Out_Time,'-') else cast(isnull(Actual_Out_Time,'-')as varchar(Max)) + ' "*"' end  as [TD],
						--		Isnull(Total_Work,'-') as [TD],
						--		Isnull(AB_Leave,'-') as [TD],
						--		Isnull(Less_Work,'-') as [TD],
						--		Isnull(More_Work,'-') as [TD],
						--		Inout_Reason As [TD]
      --                          FROM    #Temp_inout 
      --                          WHERE   
      --                          1 = (case when  @Wise = 'Branch Wise'  and Branch_Id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Department Wise' and Dept_id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Manager Wise' and manager_id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Shift Wise' and Shift_ID = @Consolidate_Id then 1
						--			when  @Wise = 'Employee Wise' and emp_id = @Consolidate_Id then 1
						--			else 0 END
      --                          )
      --                          ORDER BY  #Temp_inout.Emp_code For XML raw('tr'), ELEMENTS) 
                             
				  --SET @Body1 = ( SELECT  
						--				'Total' as [TD],
						--				'-' as [TD],
						--				'-' as [TD],
						--				'-' as [TD],
						--				DBO.F_Return_Hours(sum(cast(shift_sec as numeric(18,0)))) as [TD],
						--				'-' as [TD],
						--				'-' as [TD],
						--				DBO.F_Return_Hours(sum(cast(Total_Work_sec as numeric(18,0))))as [TD],
						--				'-' as [TD],
						--				DBO.F_Return_Hours(sum(cast(total_Less_Work_sec as numeric(18,0)))) as [TD],
						--				DBO.F_Return_Hours(sum(cast(total_More_Work_sec as numeric(18,0)))) as [TD],
						--				'-' As [TD]
      --                          FROM    #Temp_inout 
      --                          WHERE   
      --                          1 = (case when  @Wise = 'Branch Wise'  and Branch_Id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Department Wise' and Dept_id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Manager Wise' and manager_Id = @Consolidate_Id then 1
						--			WHEN  @Wise = 'Shift Wise' and Shift_ID = @Consolidate_Id then 1
						--			when  @Wise = 'Employee Wise' and emp_id = @Consolidate_Id then 1
						--			else 0 END
      --                          )
      --                          For XML raw('tr'), ELEMENTS) 
  					
      -- 			  Set @Body = Replace(@Body, '"*"', '<span style="color:red;font-size:15px;font-weight:bold">*</span>')
      -- 			  Set @Body1 = Replace(@Body1, '<tr>', '<tr style=''font-weight: bold; color: #000000; background-color: darkgrey;''>')
           		  
      --     		  SELECT  @Body = @TableHead + @Body + @Body1 + @TableTail  
      --     		  select @TableHead,@TableTail,@Body
					
				  declare @body as nvarchar(max)	
				  declare @template as varchar(max)
				  select @template  = Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Email_Type ='Inout Auto Mail' and Cmp_ID=@cmp_id_Pass
      
					declare @str_Header as nvarchar(500)
					set @str_Header = ''
					SELECT @str_Header = @str_Header  + quotename(data) from dbo.split(@column,',')
					set @str_Header = replace(@str_Header,'[','<TD>')
					set @str_Header = replace(@str_Header,']','</TD>')
					set @str_Header = '<table Width="100%"><tr style="Font-Weight:Bold;background-color: #ccc;color: #080808;">' + @str_Header + '</tr>'
					declare @str_Data as nvarchar(max) = null
					declare @str_Data_Final as nvarchar(max) 
					
					--set @str_Data = ''
					--SELECT @str_Data = COALESCE(@str_Data + ' as [TD] ,' , '') +  quotename(data) from dbo.split(@column,',')
					SELECT @str_Data = COALESCE(@str_Data + ',' ,'') +  'isnull(' + QUOTENAME(cast(Data as varchar(max))) + ','''') as [TD] ' from dbo.split(@column,',')
					
					declare @str_Data1 as nvarchar(max)
					set @str_Data1 = ' FROM    #Temp_inout 
                                WHERE   
                                1 = (case when  ''' + @Wise + ''' = ''Branch Wise''  and Branch_Id = '+ cast(@Consolidate_Id as varchar)+' then 1
									WHEN  '''+ @Wise +'''= ''Department Wise'' and Dept_id = '+ cast(@Consolidate_Id as varchar) +' then 1
									WHEN  '''+ @Wise +''' = ''Manager Wise'' and manager_id = '+ cast(@Consolidate_Id as varchar) +' then 1
									WHEN  '''+ @Wise +''' = ''Shift Wise'' and Shift_ID = '+ cast(@Consolidate_Id as varchar) +' then 1
									when  '''+ @Wise +''' = ''Employee Wise'' and emp_id = '+ cast(@Consolidate_Id as varchar) + 'then 1
									else 0 END )
                                ORDER BY  #Temp_inout.Emp_code For XML raw(''tr''), ELEMENTS)' 
					
					set @str_Data_Final = 'Set @retvalOUT = (select ' + @str_Data+ ' ' + @str_Data1
					declare @str_Footer as nvarchar(max)
					
				  declare @ParmDefinition nvarchar(MAX);
				  SET @ParmDefinition = N'@retvalOUT NVarchar(max) OUTPUT';
				  EXEC sp_executesql @str_Data_Final,@ParmDefinition, @retvalOUT=@str_Footer OUTPUT;
					 
				  select @template = replace(@template,'#Column_Detail#', @str_Header + @str_Footer + '</table>')
				  select @template = REPLACE(@template,'#From_Date#',convert(varchar(15),@From_Date,103))
				  select @template = REPLACE(@template,'#To_date#',convert(varchar(15),@To_date,103))
				  select @template = REPLACE(@template,'#Name#',convert(varchar(15),isnull(@Consolidate_Name,''),103))
					
				  set @body = @template
           		  
           		  Declare @subject as varchar(max)       
           		  if @Subject_para =''
           		  begin    
           			Set @subject = 'Inout Report ( ' + @Date + ' )'
           		  end
           		  else
           		  begin 
           			Set @subject = @Subject_para
           		  end
           		  
           		  Declare @profile as varchar(50)
				  set @profile = ''
				  
				  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK)  where cmp_id = @cmp_id_Pass
				  
				  if isnull(@profile,'') = ''
				  begin
					select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
				  end
           		   select @Consolidate_Email_id,@body
					if (@Consolidate_Email_id<>'' or @CC_Email<>'') and isnull(@body ,'') <> ''
						begin
						print 1
							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Consolidate_Email_id, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'hardik@orangewebtech.com'  
						end
					Set @Consolidate_Email_id = ''
					Set @Consolidate_Name = ''
				--Set @ECount = 0
			
		 fetch next from Cur_Consolidate into @Consolidate_Id
	   end                    
	close Cur_Consolidate                    
	deallocate Cur_Consolidate         

End

