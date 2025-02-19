


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 19-08-2017
-- Description:	Escalation of Ticket Application is not close in time matrix
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Ticket_Application_Escalation]
	@Cmp_ID Numeric = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Escalation_Hours Numeric
	Set @Escalation_Hours = 0
	--Select @Escalation_Hours = Setting_Value From T0040_SETTING Where Cmp_ID = @Cmp_ID and Setting_Name = 'Ticket Request Application Escalation hours'
	
	Declare @Emp_Full_Name as varchar(100)
	Declare @Ticket_Type as Varchar(100)
	Declare @Ticket_Dept_Name as Varchar(100)
	Declare @Ticket_Gen_Date as Datetime
	Declare @Ticket_Priority as Varchar(10)
	Declare @Ticket_Status as Varchar(10)
	Declare @Ticket_Dept_ID as Numeric(5,0)
	Declare @Emp_Branch Numeric(5,0)
	Declare @Emp_ID Numeric(5,0)
	DECLARE @Is_candidate INT --added on 27/09/2017
	
	Declare @Branch_ID_Multi Varchar(500)
	Declare @Login_ID Numeric(10,0)
	Declare @Ticket_App_ID Numeric(18,0)
	Set @Ticket_App_ID = 0
	
	Declare @Alpha_Emp_Code Varchar(50)
	
	Declare @Emp_Dept_ID Numeric(10,0)
	
	Declare  @TableHead varchar(max),
			 @TableTail varchar(max),
			 @Body varchar(max)
	
	if Object_ID('tempdb..#Email_Branch') is not null
		Begin
			Drop TABLE #Email_Branch
		End
	
	CREATE TABLE #Email_Branch
	(
		Login_ID numeric(18,0),
		Branch_Id numeric(18,0)
	)
	
	if Object_ID('tempdb..#Temp_CC') is not null
		Begin
			Drop TABLE #Temp_CC
		End
		
	CREATE TABLE #Temp_CC(Emp_ID Numeric(18,0))
	
	Declare @To_Email_Send Varchar(Max)
	Set @To_Email_Send = ''
	
	Declare @Assign_To_Emp Varchar(Max)
	Set @Assign_To_Emp = ''
	
	Declare @Assign_To_EmpCode Varchar(Max)
	Set @Assign_To_EmpCode = ''
	
	Declare @Tran_ID_Escalation As Numeric(18,0)
	
	--if @Escalation_Hours > 0
		--Begin
			
			Declare Cur_Ticket_Emp Cursor for
			Select Emp_Full_Name,Ticket_Type,Ticket_Dept_Name,Ticket_Gen_Date,Ticket_Priority,Ticket_Status,Ticket_Dept_ID,Emp_ID,Ticket_App_ID,Alpha_Emp_Code,isnull(Is_Candidate,0)Is_Candidate,Escalation_Hours
				FROM V0090_Ticket_Application Where Ticket_Status = 'Open' and is_Escalation = 0 
				--and DATEDIFF(ss,Ticket_Gen_Date,GETDATE()) > (@Escalation_Hours * 3600) and Cmp_ID = @Cmp_ID 
				and DATEDIFF(ss,Ticket_Gen_Date,GETDATE()) > (Escalation_Hours * 3600) and Cmp_ID = @Cmp_ID and Escalation_Hours > 0
			Open Cur_Ticket_Emp
			fetch next from Cur_Ticket_Emp into @Emp_Full_Name,@Ticket_Type,@Ticket_Dept_Name,@Ticket_Gen_Date,@Ticket_Priority,@Ticket_Status,@Ticket_Dept_ID,@Emp_ID,@Ticket_App_ID,@Alpha_Emp_Code,@Is_candidate,@Escalation_Hours
				While @@Fetch_Status = 0
					Begin 							
							If @Is_candidate = 0
								BEGIN
									SELECT	@Emp_Branch = I1.BRANCH_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK)
											INNER JOIN (
															SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
															FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																INNER JOIN (
																				SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																				FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																				WHERE	I3.Increment_Effective_Date <= GETDATE() and I3.Emp_ID = @Emp_ID
																				GROUP BY I3.Emp_ID
																			) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
															WHERE	I2.Cmp_ID = @Cmp_Id 
															GROUP BY I2.Emp_ID
														) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
									WHERE	I1.Cmp_ID=@Cmp_Id
								END
							ELSE
								BEGIN
									SELECT @Emp_Branch = R.Branch_id
									FROM T0060_RESUME_FINAL R WITH (NOLOCK)
									WHERE Cmp_ID = @Cmp_Id and R.Resume_ID = @Emp_ID									
								END									
							if @Ticket_Dept_ID = 1 -- For IT 
								Begin
									Declare CurEmailHr cursor for 
									Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
									Where Cmp_ID = @Cmp_ID And IS_IT = 1 and Is_Active =1
												
									Open CurEmailHr
										fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
									while @@fetch_status = 0
											begin	
													Insert into #Email_Branch
													 select @Login_ID,data
													 from dbo.Split(@Branch_ID_Multi,',')
													 where (data = @emp_branch or data = 0) 
													   
												fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
											end
									close CurEmailHr
									deallocate CurEmailHr
									
									Insert into #Temp_CC
									Select DISTINCT L.Emp_ID
									From  T0011_LOGIN L WITH (NOLOCK) inner join #Email_Branch EB on EB.Login_ID = L.Login_ID 
									Where Cmp_ID = @Cmp_ID And Is_IT = 1 and Is_Active =1 
									and(EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
										
								End 
							Else if @Ticket_Dept_ID = 2 -- For HR
								Begin
									Declare CurEmailHr cursor for 
									Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
									Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1
											
									Open CurEmailHr
									fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
									while @@fetch_status = 0
										begin	
												Insert into #Email_Branch
												 select @Login_ID,data
												 from dbo.Split(@Branch_ID_Multi,',')
												 where (data = @emp_branch or data = 0) 
											fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
										end
									close CurEmailHr
									deallocate CurEmailHr
									
									Insert into #Temp_CC
									Select DISTINCT L.Emp_ID 
									From  T0011_LOGIN L WITH (NOLOCK) inner join #Email_Branch EB on EB.Login_ID = L.Login_ID 
									Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1 
									and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
								End
							Else if @Ticket_Dept_ID = 3 -- For Account
								Begin
									Declare CurEmailAcc cursor for 
									Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
									Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active =1
										
									Open CurEmailAcc
									fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
									while @@fetch_status = 0
										begin
												Insert into #Email_Branch
												select @Login_ID,data
												from dbo.Split(@Branch_ID_Multi,',')
												where (data = @emp_branch or data = 0)
											fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
										end
									close CurEmailAcc
									deallocate CurEmailAcc
									
									Insert into #Temp_CC
									Select DISTINCT L.Emp_ID 
									From T0011_LOGIN L WITH (NOLOCK) inner join #Email_Branch EB on EB.Login_ID = L.Login_ID 
									Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active=1
									and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
								End
							Else if @Ticket_Dept_ID = 4 -- For Account
								Begin
									Declare CurEmailHelpDesk cursor for 
									Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
									Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active =1
											
									Open CurEmailHelpDesk
									fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
									while @@fetch_status = 0
										begin
											Insert into #Email_Branch
											 select @Login_ID,data
											 from dbo.Split(@Branch_ID_Multi,',')
											 where (data = @emp_branch or data = 0)
											fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
										end
									close CurEmailHelpDesk
									deallocate CurEmailHelpDesk
										
									Insert into #Temp_CC
									Select  L.Emp_ID 
									From T0011_LOGIN L WITH (NOLOCK) inner join #Email_Branch EB on EB.Login_ID = L.Login_ID 
									Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active=1
									and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0)
								End
								
								Select  @To_Email_Send =
								(
									SELECT EM.Work_Email + ';' FROM #Temp_CC TC INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
									ON TC.Emp_ID = EM.Emp_ID for xml path('')
								)
								
								Select  @Assign_To_Emp =
								(
									SELECT DISTINCT EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name + ';' FROM #Temp_CC TC INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
									ON TC.Emp_ID = EM.Emp_ID  for xml path('')
								)
								
								Set @TableHead = ''
								Set @TableHead ='<html xmlns="http://www.w3.org/1999/xhtml">
								<head>
								<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
								<title>Message From Online Payroll</title>
								<style type="text/css">
									body
									{
										margin-left: 0px;
										margin-top: 0px;
										margin-right: 0px;
										margin-bottom: 0px;
									}
									.body
									{
										margin-left: 0px;
										margin-top: 0px;
										margin-right: 0px;
										margin-bottom: 0px;
									}
									.skyblue
									{
										color: #7FDFFF;
										font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
										font-size: 24px;
									}
									.awards
									{
										font-size: 8.5pt;
										color: #000000;
										font-family: Tahoma, Verdana, Arial,Helvetica, sans-serif;
										text-decoration: none;
										line-height: 15px;
									}
									.awards_detail
									{
										font-size: 15px;
										color: #FFCC00;
										font-family: arial;
										text-decoration: none;
										font-weight: bold;
										line-height: 20px;
									}
									.awards_detail1
									{
										font-size: 11px;
										color: #FFCC00;
										font-family: Verdana;
										font-weight: 300;
										text-align: justify;
										line-height: 17px;
										font-stretch: normal;
										font-weight: 100;
										font-style: normal;
									}
									.awards_detail1_new
									{
										font-size: 12px;
										color: #333333;
										font-family: Arial;
										font-weight: 300;
										text-align: justify;
										line-height: 18px;
										font-stretch: normal;
										font-weight: 100;
										font-style: normal;
									}
									.awards_detail1_orange
									{
										font-size: 11px;
										color: #FF9900;
										font-family: Verdana;
										font-weight: 300;
										text-align: justify;
										line-height: 18px;
										font-stretch: normal;
										font-weight: 100;
										font-style: normal;
									}
									.dear_tab
									{
										background-image: url(images/deartab.jpg);
										background-position: left;
										background-repeat: no-repeat;
										font-family: arial;
										text-decoration: none;
										font-weight: normal;
										font-size: 18px;
										width: 53px;
										height: 26px;
										color: #7FDFFF;
										text-align: center;
										vertical-align: middle;
									}
									.name_dear_tab
									{
										background-image: url(images/afterdeartab.jpg);
										background-position: left;
										background-repeat: no-repeat;
										font-family: arial;
										text-decoration: none;
										font-weight: normal;
										font-size: 14px;
										width: 456px;
										height: 26px;
										color: #7FDFFF;
										text-align: left;
										vertical-align: middle;
									}
									.leave-detail_tab
									{
										background-image: url(images/leavedetail.jpg);
										background-position: left;
										background-repeat: no-repeat;
										font-family: arial;
										text-decoration: none;
										font-weight: normal;
										font-size: 18px;
										width: 509px;
										height: 26px;
										color: #7FDFFF;
										text-align: left;
										padding-left: 13px;
									}
									.message-from
									{
										font-family: arial;
										text-decoration: none;
										font-weight: normal;
										font-size: 18px;
										color: #7FDFFF;
										line-height: 20px;
									}
									.White
									{
										font-family: Verdana;
										font-size: 10pt;
										color: #ffffff;
										text-align: left;
										text-decoration: none;
									}
									.White_small
									{
										font-family: Verdana;
										font-size: 9pt;
										color: #ffffff;
										text-align: left;
										text-decoration: none;
									}
								</style>
								<link href="style.css" rel="stylesheet" type="text/css" />
							</head>
							<body>
								<table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
									<tr>
										<td align="center" valign="bottom">
											<table width="580" border="0" cellspacing="0" cellpadding="0">
												<tr>
													<td width="10" align="left" valign="top" bgcolor="#3D3C4C">
														&nbsp;
													</td>
													<td width="560" align="left" valign="top" bgcolor="#3D3C4C">
														<table width="572" height="56" border="0" cellpadding="0" cellspacing="0">
															<tr>
																<td width="491" height="37" align="center" valign="bottom" style="padding-bottom: 10px;
																	color: #7FDFFF; font-family: Verdana; font-size: large">
																	Message From Online Payroll
																</td>
															</tr>
															<tr>
																<td align="center" style="font-family: Verdana; font-size: 12pt; color: #ffffff;
																	text-decoration: none; padding-bottom: 10px;">
																	Open Ticket Escalation('+ Cast(@Escalation_Hours AS varchar(10))  +' hrs)
																</td>
															</tr>
														</table>
													</td>
													<td width="10" align="right" valign="top" bgcolor="#3D3C4C">
														&nbsp;
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr>
										<td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
											width: 509px; height: 26px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
											Ticket Details
										</td>
									</tr>
									<tr>
										<td height="237" align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;">'
											Set @TableTail = '<table width="473" border="0" align="center" cellpadding="0" cellspacing="0">
												<tr>
													<td align="left" valign="bottom" bgcolor="#5f6275">
														<table width="100%" border="0" align="left" cellpadding="0" cellspacing="0">
															<tr>
																<td width="100%" align="center" valign="top">
																	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
																		<tr>
																			<td height="8" colspan="3">
																			</td>
																		</tr>
																		<tr>
																			<td width="120" height="25" align="right" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																					Applicant Name</div>
																			</td>
																			<td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Alpha_Emp_Code + '-' + @Emp_Full_Name + '
																			</td>
																		</tr>
																		<tr>
																			<td height="25" align="right" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																					Ticket For
																				</div>
																			</td>
																			<td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Ticket_Type + '
																			</td>
																		</tr>
																		<tr>
																			<td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																					Ticket Assign 
																				</div>
																			</td>
																			<td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Ticket_Dept_Name + '
																			</td>
																		</tr>
																		<tr>
																			<td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																					Ticket Date 
																				</div>
																			</td>
																			<td height="25" align="center" valign="middle" style="font-family: Verdana; font-size: 10pt;
																				color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + Replace(Convert(Varchar(10),Cast(@Ticket_Gen_Date AS datetime),104),'.','-') + REPLACE(REPLACE(SUBSTRING(Cast(@Ticket_Gen_Date AS varchar(30)),12,8),'AM',' AM'),'PM',' PM') + '
																			</td>
																		</tr>
																		<tr>
																			<td width="93" height="25" align="right" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																				   Ticket Priority
																				</div>
																			</td>
																			<td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Ticket_Priority + '
																			</td>
																		</tr>
																		<tr>
																			<td width="93" height="25" align="right" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																				   Ticket Status
																				</div>
																			</td>
																			<td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Ticket_Status + '
																			</td>
																		</tr>
																		<tr>
																			<td width="93" height="25" align="right" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="right">
																				   Assign To
																				</div>
																			</td>
																			<td width="44" height="25" align="center" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																				<div align="center">
																					:
																				</div>
																			</td>
																			<td width="163" height="25" align="left" valign="middle" style="font-family: Verdana;
																				font-size: 10pt; color: #ffffff; text-align: left; text-decoration: none;">
																					' + @Assign_To_Emp + '
																			</td>
																		</tr>
																		<tr>
																			<td height="8" colspan="3">
																			</td>
																		</tr>
																	</table>
																</td>
															</tr>
														</table>
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr>
										<td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
											font-size: 9pt; color: #ffffff; text-align: left; text-decoration: none;">
											<div align="left">
												&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Do not reply to this mail, this is a system generated
												mail.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
										</td>
									</tr>
								</table>
							</body>
							</html>'
							Set @Body = @TableHead + @TableTail
							
							Declare @profile as varchar(50)
       						set @profile = ''
       					    
       						select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       						
       						if isnull(@profile,'') = ''
       							begin
       								select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       							end  	
							
							--SELECT  @profile,  @To_Email_Send,  'Open Ticket Escalation',  @Body, 'HTML', ''
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @To_Email_Send, @subject = 'Open Ticket Escalation', @body = @Body, @body_format = 'HTML',@copy_recipients = ''
							
							Update T0090_Ticket_Application SET Is_Escalation = 1 Where Ticket_App_ID = @Ticket_App_ID
							
							Set @Tran_ID_Escalation = 0
							Select @Tran_ID_Escalation = Isnull(MAX(Tran_ID),0) + 1 From T0095_Ticket_Escalation WITH (NOLOCK)
							if @Tran_ID_Escalation > 0
								Begin
									Insert INTO T0095_Ticket_Escalation VALUES(@Tran_ID_Escalation,@Ticket_App_ID,@Emp_ID,GETDATE(),Replace(@To_Email_Send,';',','),1)
								End
								
								DELETE FROM #Email_Branch
								DELETE FROM #Temp_CC
						fetch next from Cur_Ticket_Emp into @Emp_Full_Name,@Ticket_Type,@Ticket_Dept_Name,@Ticket_Gen_Date,@Ticket_Priority,@Ticket_Status,@Ticket_Dept_ID,@Emp_ID,@Ticket_App_ID,@Alpha_Emp_Code,@Is_candidate,@Escalation_Hours
					End
			close Cur_Ticket_Emp
			deallocate Cur_Ticket_Emp
			
			DROP TABLE #Email_Branch
			DROP TABLE #Temp_CC
		--End
END

