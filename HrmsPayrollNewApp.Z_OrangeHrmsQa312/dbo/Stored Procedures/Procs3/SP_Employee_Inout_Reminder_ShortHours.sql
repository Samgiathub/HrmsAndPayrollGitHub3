

-- Created by rohit for late early and deduct days reminder on 04072016
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Inout_Reminder_ShortHours]
	@flag  numeric = 1 -- For Send Report Monthly - 01-jan to 31 jan
	--,@flag  numeric = 2 for Send report Weekly 01-jan -07-jan
	--,@flag  numeric = 2 for Send Report Daily 01 - jan to 01-jan
	,@cmp_id_Pass Numeric(18,0) = 1,
	@CC_Email Nvarchar(max) = ''
AS 
BEGIN   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      --Declare @flag as tinyint
      --set @flag = 2
      Declare @From_Date as Datetime
      Declare @To_Date as Datetime
      SET @DATE = CAST(GETDATE() AS varchar(11))
      
      if @flag = 1
      BEGIN 
		set @To_Date = cast(DATEADD(dd,-(DAY(Getdate())),getdate()) as varchar(max))
		set @From_Date = cast(DATEADD(dd,-(DAY(@To_Date)-1),@To_Date) as varchar(max))
      END
      else if @flag = 2
      Begin
      set @To_Date = cast(DATEADD(day,
               -2 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7,
               GETDATE()) as varchar)
               
		set @From_Date = cast(DATEADD(dd, -(DATEPART(dw, @To_Date)-1), @To_Date) as varchar)
       
      end
      else if @flag = 3
      Begin
       set @To_Date =  cast((Getdate()-1) as varchar(max))
       set @From_Date =  cast((Getdate()-1) as varchar(max))
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
	Other_Reason varchar(300) null, --Added By Jaina 12-09-2015        
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

	--,
	--Leave_Footer varchar(max),
	--Branch_Name varchar(max)
) 
		set @from_date = REPLACE(CONVERT(VARCHAR(11),@from_date,106), ' ','-')
        set @To_Date = REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-')
        
        
        --Added by Jaina 17-01-2018
        Create Table #INOUT_DETAIL
        (
			Emp_ID		Numeric,
			Row_ID		Numeric,
			For_Date	DateTime,
			P_Days		Numeric(9,4),
			HO_Day		Numeric(5,2),
			WO_Day		Numeric(5,2),
			Leave_Days	Numeric(9,4),			
			Leave_Type	varchar(100),
			Absent      Numeric(5,2)
        )
		
		
		--select DATEADD(d , (DAY('2018-01-28') -1) * -1, DATEADD(MM,1, '2018-01-28'))
		--select DAY('2018-01-28')
		
		
		Insert Into #Temp_inout		
		exec SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@PBranch_ID='0',@Report_call = 'Inout_Mail'      
      
		
      
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Emp_ID NUMERIC(18, 0)
      )   
	 ----INSERT    INTO #Temp
  --   exec [SP_Get_Present_Absent_Emp_List] 0,@DATE 
  --   into #Temp_inout

	Insert Into #HR_Email (Emp_ID)
	Select Emp_Id From #Temp_inout Group by Emp_id
	

	Declare @EmpEmail_ID	nvarchar(4000)
	Declare @Emp_Id as numeric
	Declare @Emp_Name as varchar(255)
	--Declare @ECount as numeric
	Declare @cmp_id as numeric(18,0)
	Declare @cmp_Name as varchar(500)
	
	declare Cur_Employee cursor for                    
		select Emp_Id from #HR_Email order by Emp_Id
	open Cur_Employee                      
	fetch next from Cur_Employee into @Emp_Id
	while @@fetch_status = 0                    
		begin     
				
			SELECT TOP 1 @EmpEmail_ID = Work_Email, @Emp_Name = Emp_Full_Name,@cmp_id=E.cmp_id
			,@cmp_Name = c.Cmp_Name
			FROM T0080_EMP_MASTER E WITH (NOLOCK) inner join T0010_COMPANY_MASTER C WITH (NOLOCK) on E.Cmp_ID = C.cmp_id
			Where emp_id=@Emp_Id
			
			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableHead_2 varchar(max),
					   @TableHead_3 varchar(max),
					   @TableTail varchar(max),
					   @TableHead_1 varchar(max)  --added by Jaina 16-01-2018
					   
           		  Set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
    padding-left: 1ex">
    <style> 
    .new {text-align:center;border-collapse: collapse;border:1px solid #b0daff;width:15%}   
  	</style>
  
    <table style="background-color: #edf7fd; border-collapse: collapse; border: 1px solid #b0daff"
        align="center" cellpadding="5px" width="100%">
        <tbody>
            <tr>
                <td colspan="9">
                    Hello #Emp_Name#,
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    Please verify your leave(s) &amp; working hour(s) for the month of #monthYear#.
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    Your salary will be calculated based on verified working hour(s) &amp; leave(s)
                    taken.
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    If you find any discrepancy, please contact HR Department for correction of same
                    <span class="aBn" data-term="goog_630316155" tabindex="0"><span class="aQJ">within 24
                        hours</span></span>.
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    Please refer <a href="#Server_link#" style="color: #1155cc" target="_blank">Orange &gt;
                        My Working Hours</a> to verify your working hour(s).
                </td>
                <td colspan="9">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td colspan="9">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <th colspan="10" style="color: #3f628e; font-weight: bold" align="left">
                                    Pending work hour(s) to be verified:
                                </th>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Date</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>In Time</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Out Time</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Total Hrs</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Work Hrs</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Present Day</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Not Worked</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b> Leave Name </b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Leave</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Remarks</b>
                                </td>
                            </tr>'
                   --Added by Jaina 16-01-2018
                  set @TableHead_1 = ' <tr>
											<td colspan="10">
												<table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5" border="1px"
													cellspacing="0" width="100%">
													<tbody>
														<tr>
															<td colspan="10" style="color: #3f628e; font-weight: bold">
																Attendance Summary:
															</td>
														</tr>
														<tr>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																align="center" >
																<b>Present</b>
															</td>
															<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																align="center">
																<b>Absent</b>
															</td>
															<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																 align="center">
																<b>Leave</b>
															</td>
															<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																 align="center">
																<b>Weekoff</b>
															</td>
															<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																 align="center">
																<b>Holiday</b>
															</td>                               
														</tr>'
												         
                            
				  Set @TableHead_2 = '  <tr>
                                <td colspan="10">
                                    Please refer <a href="#Server_link#" style="color: #1155cc" target="_blank">Orange &gt;
                                        Leave Verification</a> to view your current year leave summary.
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="10">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5" border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <td colspan="10" style="color: #3f628e; font-weight: bold">
                                    Leave Summary:
                                </td>
                            </tr>
                            <tr>
                            <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" >
                                    <b>leave Name</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Total Leave</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                     align="center">
                                    <b>Leave Taken</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                     align="center">
                                    <b>Balance</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                     align="center">
                                    <b>With Pay</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>With Out Pay</b>
                                </td>
                            </tr>'
                  set @TableHead_3 = '</tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="10">
                    <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
                        cellspacing="0" width="100%">
                        <tbody>
                            <tr>
                                <td colspan="10" style="color: #3f628e; font-weight: bold">
                                    Leave Details:
                                </td>
                            </tr>
                            <tr>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" width="20%">
                                    <b>Date</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" width="20%">
                   <b>Leave Type</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" nowrap="" width="15%">
                                    <b>Total Day(s)</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center">
                                    <b>Reason</b>
                                </td>
                                <td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
                                    align="center" nowrap="" width="15%">
                                    <b>Leave Status</b>
                                </td>
                            </tr>'          
										                                     
                  SET @TableTail = '</tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: blue">
                    <small>** Your salary calculation will be done based on this data, it does not include
                        any unplanned leave you may take during remaining days of current month.</small>
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: blue">
                    <small>** Attendance cycle is #from_date# to #To_date#</small>
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: blue">
                    <small>** Any discrepancies will be handled in the next payroll.</small>
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: blue">
                    <small>** No correction will be entertained after #last_Date#. It would be your responsibility
                        to verify your leave(s) &amp; working hour(s) on a daily basis.</small>
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: blue">
                    <small>** Leave are subject to approval , unplan leave will be consider as leave without pay.</small>
                </td>
            </tr>
            <tr>
                <td colspan="10">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td colspan="10" style="color: #757677" align="left">
                    Thank you,<br>
                    HR Department
                </td>
            </tr>
            <tr>
                <td colspan="10" align="right">
                    <span style="font-family: arial; font-size: 11px; color: rgb(93,93,93)">Powered by&nbsp;</span>
                    <span><a href ="www.payrollsoftware.co.in" >ORANGE HRMS</a></span>
                </td>
            </tr>
        </tbody>
    </table>
</blockquote>'
			
			
                  DECLARE @Body AS VARCHAR(MAX)
                  DECLARE @Body1 AS VARCHAR(MAX)
                  DECLARE @Body2 AS VARCHAR(MAX)
                  DECLARE @Body3 AS VARCHAR(MAX)
                  
                  SET @Body = ( SELECT  
										(CASE WHEN isnull(AB_LEAVE,'-') = 'AB' THEN '/**/' + On_Date + '/***/' 											  
											  when ISNULL(P_Days,'-') = '0.50' AND ISNULL(AB_LEAVE,'-') = 'OD' THEN '/****/' + On_Date + '/*****/' 
											  when ISNULL(P_Days,'-') = '0.50' AND ISNULL(AB_LEAVE,'-') <> '-' THEN '/****/' + On_Date + '/*****/' 
											  WHEN isnull(P_days,'-') = '0.50' THEN '/**/' + On_Date + '/***/' 
											  ELSE On_Date END) as [tdc],
										--Isnull( dbo.F_GET_AMPM(shift_st_datetime),'-') as [TD],
										--Isnull(dbo.F_GET_AMPM(shift_en_datetime),'-') as [TD],
										--Isnull(shift_dur,'-') as [TD],
										case when isnull(late_in,'-') in ('-','') then Isnull(Actual_In_Time,'-') else cast( Isnull(Actual_In_Time,'-') as varchar(max)) + ' "*"' end  as [tdc],
										case when Isnull(early_out,'-')in('-','') then isnull(Actual_Out_Time,'-') else cast(isnull(Actual_Out_Time,'-')as varchar(Max)) + ' "*"' end  as [tdc],
										Isnull(Total_Work,'-') as [tdc],
										--Isnull('-','-') as [tdc],
										Isnull(Total_Work,'-') as [tdc],
										 ( Case when ISNULL(P_Days,'-') = '0.50' AND ISNULL(AB_LEAVE,'-') = 'OD' then '/****/' + ISNULL(P_days,'-') + '/*****/'												
												when ISNULL(P_Days,'-') = '0.50' AND ISNULL(AB_LEAVE,'-') <> '-' then '/****/' + ISNULL(P_days,'-') + '/*****/'												
												when ISNULL(P_Days,'-') = '0.50' then '/**/' + ISNULL(P_days,'-') + '/***/'												
											else ISNULL(P_Days,'-') END)as [tdc],	
										Isnull(Less_Work,'-') as [tdc],
										Isnull(AB_Leave,'-') as [tdc],
										case when ISNULL(Leave,'') <> '' then 'Yes' else 'No' end as [tdc],
										Inout_Reason As [tdc]
                                FROM    #Temp_inout 
                                WHERE   Emp_ID = @Emp_Id 
                                --and (isnull(Late_In_Sec,0) > 0 or isnull(Early_In_sec,0) > 0 or isnull(AB_Leave,'') = 'AB' or ISNULL(Leave,'') <> '' ) 
                                and (isnull(Total_Less_work_Sec ,0) > 600 or isnull(AB_Leave,'') not in ('','WO','HO') or ISNULL(Leave,'') <> '' )  -- less 10 minute allow as per ankur sir
                                ORDER BY  #Temp_inout.On_date For XML 
                                 raw('tr'), ELEMENTS) 
                            
                        
          --        	SET @Body1 = ( SELECT  
          --        					LM.leave_name as [tdc],
										--dbo.F_Lower_Round(max(Leave_Opening),LT.cmp_id) as [tdc],
										--dbo.F_Lower_Round(sum(Leave_Used),LT.Cmp_ID) as [tdc],
										--dbo.F_Lower_Round((MAX(Leave_Opening) - sum(Leave_Used)),LT.Cmp_ID) as [tdc],
										--case when isnull(LM.Leave_Paid_Unpaid,0) <> 'P' then 'No' else 'Yes' end  as [tdc],
										--case when isnull(LM.Leave_Paid_Unpaid,0)<> 'P' then 'Yes' else 'No' end as [tdc]
										--from T0140_LEAVE_TRANSACTION LT inner join  T0040_leave_master LM
										--on LT.Leave_ID = Lm.Leave_ID
										--where lt.Cmp_ID=@cmp_id and Lt.Emp_ID = @Emp_Id and Leave_Used > 0
										--and For_Date >= @From_Date and For_Date <= @To_Date
										--group by Leave_Name,Leave_Paid_Unpaid,LT.cmp_id
										--For XML raw('tr'), ELEMENTS )
									
																		
							SET @Body1 = (	SELECT  
								LM.leave_name as [tdc],
								--lm.leave_id as [tdc],
								--	case when lm.Leave_ID in (1,3) then abs(dbo.F_Lower_Round(max(Leave_Opening),LT.cmp_id)) else abs(dbo.F_Lower_Round(max(Leave_Opening),LT.cmp_id))  end as [tdc],
								--	dbo.F_Lower_Round(sum(Leave_Used),LT.Cmp_ID) as [tdc],
								--		case when lm.Leave_ID in (1,3) then abs(dbo.F_Lower_Round((MAX(Leave_Opening) - sum(Leave_Used)),LT.Cmp_ID)) else (dbo.F_Lower_Round((MAX(Leave_Opening) - sum(Leave_Used)),LT.Cmp_ID)) end as [tdc],
									CASE WHEN ISNULL(LM.Display_leave_balance,0) = 1 THEN abs(dbo.F_Lower_Round(max(Leave_Opening),LT.cmp_id)) ELSE 0 END as [tdc],
									dbo.F_Lower_Round(sum(Leave_Used),LT.Cmp_ID) as [tdc],CASE WHEN ISNULL(LM.Display_leave_balance,0) = 1 THEN abs(dbo.F_Lower_Round((MAX(Leave_Opening) - sum(Leave_Used)),LT.Cmp_ID)) ELSE 0 END AS [tdc],
									case when isnull(LM.Leave_Paid_Unpaid,0) <> 'P' then 'No' else 'Yes' end  as [tdc],
									case when isnull(LM.Leave_Paid_Unpaid,0)<> 'P' then 'Yes' else 'No' end as [tdc]
									from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join  T0040_leave_master LM WITH (NOLOCK)
									on LT.Leave_ID = Lm.Leave_ID
									where lt.Cmp_ID=@cmp_id and Lt.Emp_ID = @Emp_Id and Leave_Used > 0
									and For_Date >= @From_Date and For_Date <= @To_Date
									group by Leave_Name,Leave_Paid_Unpaid,LT.cmp_id,lm.leave_id , LM.Display_leave_balance
									For XML raw('tr'), ELEMENTS )
	
			
										
					SET @Body2 = ( SELECT  
										Convert(nvarchar(11), lt.For_Date, 113) as [tdc],
										lm.Leave_Name as [tdc],
										dbo.F_Remove_Zero_Decimal(leave_used) as [tdc],
										Leave_Reason as [tdc],
										'Approved' as [tdc]
										from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
										
										--from T0130_LEAVE_APPROVAL_DETAIL LAD inner join 
										--T0120_LEAVE_APPROVAL LA on lad.Leave_Approval_ID = la.Leave_Approval_ID 
										inner join  T0040_leave_master LM WITH (NOLOCK)
										on LT.Leave_ID = Lm.Leave_ID left join
										(select LAD.*,La.emp_id from T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) inner join T0120_LEAVE_APPROVAL LA WITH (NOLOCK) on LAD.Leave_Approval_ID = la.Leave_Approval_ID 
										where LA.Emp_ID=@Emp_Id and la.Cmp_ID=@cmp_id and LAD.Leave_Period > 0 and Approval_Status ='A'  ) LADT on LT.Emp_ID = LADT.Emp_ID and LT.Leave_ID =ladt.Leave_ID 
										and lt.For_Date >= ladt.From_Date and lt.For_Date<=ladt.To_Date
										where LT.Cmp_ID=@cmp_id and LT.Emp_ID = @Emp_Id and LT.Leave_Used > 0
										and( For_Date>= @From_Date and for_date <= @To_Date )
										order by lt.For_Date
										
										For XML raw('tr'), ELEMENTS)					
					
							   
				   set @Body3 = (
									SELECT dbo.F_Remove_Zero_Decimal(P_Days) as [tdc],
											Absent as [tdab],
											dbo.F_Remove_Zero_Decimal(Leave_Days) as [tdc],
											WO_Day as [tdc],
											HO_Day as [tdc]											
									FROM #INOUT_DETAIL where Row_id = 9999
									AND Emp_ID = @Emp_Id
									For XML raw('tr'), ELEMENTS)  --Added by Jaina 16-01-2018
					
           		   Set @Body = Replace(@Body, '"*"','<span style="color:red;font-size:15px;font-weight:bold">*</span>')
				   Set @Body = Replace(@Body, '/**/','<span style="color:red;">')
				   Set @Body = Replace(@Body, '/***/','</span>') 
				    Set @Body = Replace(@Body, '/****/','<span style="color:black;">')
				    Set @Body = Replace(@Body, '/*****/','</span>') 
           	  
           		 -- SELECT  @Body = @TableHead + @Body + @TableTail
           		 
           		 
           		 if isnull(@Body2,'') = ''
           		 begin
           			SELECT  @Body = isnull(@TableHead,'') + isnull(@Body,'') + isnull(@TableHead_1,'') + ISNULL(@Body3,'') + isnull(@TableHead_2,'') + ISNULL(@Body1,'') + isnull(@TableTail,'')  
           		 end
           		 else
           		 begin
           			SELECT  @Body = isnull(@TableHead,'') + isnull(@Body,'') + isnull(@TableHead_1,'') + ISNULL(@Body3,'') + isnull(@TableHead_2,'') + ISNULL(@Body1,'') + ISNULL(@TableHead_3,'') + isnull(@Body2,'') + isnull(@TableTail,'')    --Change by Jaina 16-01-2018
           		  end
           		  
           		
           		  
           		  SET @body = REPLACE(@body, '<tdc>', '<td class="new" align="center">')
           		  SET @body = REPLACE(@body, '<td class="new" align="center">AB</tdc>', '<td class="new" align="center"><span style="color:red;">AB</span></tdc>')
           		  --SET @body = REPLACE(@body, '<td class="new" align="center">0.50</tdc>', '<td class="new" align="center"><span style="color:red;">0.50</span></tdc>')
           		  SET @body = REPLACE(@body, '<tdab>', '<td class="new" align="center"> <span style="color:red;">')
           		             			
           		  
           		  Declare @subject as varchar(max)           
           		  Set @subject = 'Inout - Leave Verification ( ' + Convert(nvarchar(11), @From_Date, 113)  + ' to ' + Convert(nvarchar(11), @To_Date, 113)   +' )'
           		  
           		   
           		  
				  Declare @profile as varchar(50)
				  set @profile = ''
				  declare @server_link as varchar(500)
				  
				  select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link  from t9999_Reminder_Mail_Profile where cmp_id = @Cmp_Id
				  
				  if isnull(@profile,'') = ''
				  begin
				  select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link from t9999_Reminder_Mail_Profile where cmp_id = 0
				  end
				  
				  DECLARE @Body_final AS VARCHAR(MAX)
				  declare @monthyear as varchar(15)
				  set @monthyear = CONVERT(CHAR(4), @To_Date, 100) + CONVERT(CHAR(4), @To_Date, 120) 
           		  
           		  set @Body_final = REPLACE(@Body ,'#Emp_Name#',@Emp_Name)  
           		  set @Body_final = REPLACE(@Body_final ,'#monthYear#',@monthyear)  
           		  set @Body_final = REPLACE(@Body_final ,'#Server_link#',@server_link)  
           		  set @Body_final = REPLACE(@Body_final ,'#from_date#', Convert(nvarchar(11), @From_Date, 113))  
           		  set @Body_final = REPLACE(@Body_final ,'#To_date#', Convert(nvarchar(11), @To_Date, 113))  
           		  set @Body_final = REPLACE(@Body_final ,'#last_Date#',Convert(nvarchar(11), dateadd(dd,1,@DATE), 113) ) 
           		  set @Body_final = REPLACE(@Body_final ,'#cmp_Name#',@cmp_name )  


           		 --select @Body_final 		 	 
			if (@EmpEmail_ID<>'' or @CC_Email<>'') and isnull(@Body,'') <> ''
				begin
			--select @Body
		
			
					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @EmpEmail_ID, @subject = @subject, @body = @Body_final, @body_format = 'HTML',@copy_recipients = @CC_Email,@blind_copy_recipients = 'jaina@orangewebtech.com' --'orangeqa4@gmail.com'
					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'hardik@orangewebtech.com'  
				end
			Set @EmpEmail_ID = ''
			Set @Emp_Name = ''
			--Set @ECount = 0
			
			
		 fetch next from Cur_Employee into @emp_id
	   end                    
	close Cur_Employee                    
	deallocate Cur_Employee         

End

