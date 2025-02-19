

-- =============================================
-- Author:		<Jaina Desai>
-- Create date: <16-06-2017>
-- Description:	<Retirement Reminder>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Employee_Retirement_Reminder]
	@cmp_id_Pass Numeric(18,0) = 0,	
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Cmp_Id numeric(18,0)
	Declare @Days INT
	Declare @EMAIL_NTF_SENT AS Numeric(1,0)
	Declare @To_Manager AS Tinyint
	Declare @To_Hr As Tinyint
	Declare @To_Account As Tinyint
	Declare @Other_Email As Varchar(max)
	Declare @Is_Manager_CC As Tinyint
	Declare @Is_HR_CC As Tinyint
	Declare @Is_Account_CC  As Tinyint
	
	set @Cmp_Id = @cmp_id_Pass
	set @Days = 60
	
	IF OBJECT_ID('tempdb..#EMP_RETIREMENT') IS NOT NULL 
	BEGIN
			  DROP TABLE #EMP_RETIREMENT
	END
	CREATE TABLE #EMP_RETIREMENT
	(
		Cmp_Id numeric(18,0),
		Emp_ID numeric(18,0),
		Branch_ID numeric(18,0),
		Alpha_Emp_Code varchar(250),
		Emp_Full_Name varchar(500),
		Branch_Name varchar(500),
		Date_Of_Join datetime,
		Date_of_Retirement datetime,
		Desig_ID numeric(18,0),
		Desig_Name varchar(500),
		Emp_Superior numeric(18,0)
		
	)
	
	
	
	exec SP_Get_Employee_Retirement_Records @Cmp_ID=@Cmp_Id,@Type=2,@Days=@Days,@StrWhere=''
	
	ALTER TABLE #EMP_RETIREMENT ADD Manager_Email varchar(max) 
	ALTER TABLE #EMP_RETIREMENT ADD HR_Email varchar(max) 
	ALTER TABLE #EMP_RETIREMENT ADD ACC_Email varchar(max) 
	ALTER TABLE #EMP_RETIREMENT ADD Other_Email varchar(max) 
	
	
	
	Select @EMAIL_NTF_SENT = EMAIL_NTF_SENT From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID 
	And EMAIL_TYPE_NAME = 'Employee Retirement'
	
	--select * from #EMP_RETIREMENT
	
	CREATE TABLE #Email_Branch
	(
		Login_ID numeric(18,0),
		Branch_Id numeric(18,0)
	 )
	DECLARE @emp_branch AS NUMERIC
	Declare @Branch_ID_Multi nvarchar(max)
		set @Branch_ID_Multi = ''
	Declare @Login_Id numeric(18,0)
		set @Login_Id = 0
		
	
				
	IF @EMAIL_NTF_SENT = 1
		BEGIN
			Select @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
					   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC
							From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME ='Employee Retirement'

			IF @To_Manager = 1 or @Is_Manager_CC = 1
			BEGIN
				update R SET R.Manager_Email = Work_Email
				FROM T0080_EMP_MASTER E inner join 
					 #EMP_RETIREMENT R ON R.Emp_Superior = E.Emp_ID
							
			END
			
			
			If @To_Hr = 1 or @Is_HR_CC = 1 
				Begin
					
												
					UPDATE	R
					SET		HR_Email = L.Email_ID
					FROM	#EMP_RETIREMENT R
							CROSS APPLY  (SELECT	EMP_ID, L.Email_ID
										  FROM		T0011_LOGIN  L WITH (NOLOCK)
										  WHERE		L.Cmp_ID=@CMp_ID AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
													and IS_HR = 1 AND IS_ACTIVE=1 ) L 
					
					
					--Declare CurEmailHr cursor for 
					--	Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN 
					--	Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1
						
					--Open CurEmailHr
					--	fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
					-- while @@fetch_status = 0
					--	begin	
													   
					--			Insert into #Email_Branch
					--			 select DISTINCT @Login_ID,data
					--			 from dbo.Split(@Branch_ID_Multi,',') inner join 
					--			 #EMP_RETIREMENT R on R.Branch_ID = Data
								 
					--		fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
					--	end
					--close CurEmailHr
					--deallocate CurEmailHr
				
					--If @Is_HR_CC = 1 or @To_Hr = 1				 
					--		UPDATE R SET  HR_Email =(ISNULL(Email_ID,'')) From T0011_LOGIN L 
					--		inner join
					--		#Email_Branch EB on EB.Login_ID = L.Login_ID 
					--		inner JOIN #EMP_RETIREMENT R ON R.Branch_ID = EB.Branch_Id
					--		Where R.Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active=1										
				End
			
			
			If @To_Account = 1	or @Is_Account_CC = 1
				Begin
						
					UPDATE	R
					SET		ACC_Email = L.Email_ID_accou
					FROM	#EMP_RETIREMENT R
							CROSS APPLY  (SELECT	EMP_ID, L.Email_ID_accou
										  FROM		T0011_LOGIN  L WITH (NOLOCK)
										  WHERE		L.Cmp_ID=@CMp_ID AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
													And Is_Accou = 1 and Is_Active =1 ) L 
														
					--Declare CurEmailAcc cursor for 
					--	Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN 
					--	Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active =1
						
					--Open CurEmailAcc
					--	fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
					-- while @@fetch_status = 0
					--	begin	
					--			Insert into #Email_Branch
					--			 select DISTINCT @Login_ID,data
					--			 from dbo.Split(@Branch_ID_Multi,',') inner join 
					--			 #EMP_RETIREMENT R on R.Branch_ID = Data
								 
								   
					--		fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
					--	end
					--close CurEmailAcc
					--deallocate CurEmailAcc
					
					--If @Is_Account_CC = 1 or @To_Account = 1
					--	Begin				
					--		UPDATE R SET  ACC_Email =(ISNULL(Email_ID_accou,'')) From T0011_LOGIN L 
					--		inner join
					--		#Email_Branch EB on EB.Login_ID = L.Login_ID 
					--		inner JOIN #EMP_RETIREMENT R ON R.Branch_ID = EB.Branch_Id
					--		Where R.Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active=1
							
					--	END
							
				End
				IF @Other_Email <> ''
						update R set Other_Email = @Other_Email from #EMP_RETIREMENT R
		END	
	ELSE
		return
	
	--select * from #EMP_RETIREMENT
	
	DECLARE @R_EMP_ID NUMERIC
	DECLARE @CMP_NAME VARCHAR(MAX)
	DECLARE @MANAGER_EMAIL VARCHAR(MAX)
	DECLARE @HR_EMAIL VARCHAR(MAX)
	DECLARE @ACC_EMAIL VARCHAR(MAX)
	DECLARE @O_EMAIL VARCHAR(MAX)
	DECLARE @BODY AS VARCHAR(MAX)
	DECLARE @TABLEHEAD VARCHAR(MAX)
	DECLARE	@TABLETAIL VARCHAR(MAX)
	DECLARE @TO_EMAIL_DETAIL VARCHAR(MAX)
	DECLARE @CC_EMAIL_DETAIL VARCHAR(MAX)

			declare Employee_Retire cursor for  
				
				select	Manager_Email,HR_Email,ACC_Email,Other_Email 
				from	#EMP_RETIREMENT 
				GROUP BY Manager_Email,HR_Email,ACC_Email,Other_Email 					
				
				open Employee_Retire                				      
				fetch next from Employee_Retire into @MANAGER_EMAIL,@HR_EMAIL,@ACC_EMAIL,@O_EMAIL
				while @@fetch_status = 0                    
					begin    
						SET @TO_EMAIL_DETAIL = NULL;
						SET @CC_EMAIL_DETAIL = NULL;
						
						
						IF @To_Manager = 1 
						begin
							SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ',', '') + isnull(@MANAGER_EMAIL,'')
						end
						ELSE IF @Is_Manager_CC = 1
							SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ',', '') + isnull(@MANAGER_EMAIL,'')
												
											
						IF @IS_HR_CC = 1 
							SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ',', '') + isnull(@HR_EMAIL,'')
						ELSE IF @TO_HR = 1
						BEGIN
							select @TO_EMAIL_DETAIL as to_email
							SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ',', '') + isnull(@HR_EMAIL,'')
						end	
						
						
						if @Is_Account_CC = 1
							SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ',', '') + isnull(@ACC_EMAIL,'')
						else
							SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ',', '') + isnull(@ACC_EMAIL,'')
																	
						IF @Other_Email <> ''
							SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ',', '') + isnull(@O_EMAIL,'')
												
						
												
						declare @style varchar(max)
						set @style = 'text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';
						
						    	 
						set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
							padding-left: 1ex">
							<style> 
							.new {text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff}   
  							</style>
						  
							<table style="background-color: #edf7fd; border-collapse: collapse; border: 1px solid #b0daff"
								align="center" cellpadding="5px" width="100%">
								<tbody>
						                      
									<tr>
										<td colspan="9">
											Please verify retirement employee detail for your team.
											
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
															Retirement Detail
														</th>
													</tr>
													<tr>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="center">
															<b>Employee Name</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="center">
															<b>Branch</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="center">
															<b>Designation</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="center">
															<b>Joining Date</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="center">
															<b>Retirement Date</b>
														</td>
													</tr>'
											
									
				 set @TableTail = '
												</tbody>
											</table>
										</td>
									</tr>
									 <tr>
									<td colspan="9">
										&nbsp;
									</td>
									</tr>
									<tr>
										<td colspan="9" style="color: #757677" align="left">
											Thank you,<br>
											HR Department
										</td>
									</tr>
									<tr>
										<td colspan="9" align="right">
											<span style="font-family: arial; font-size: 11px; color: rgb(93,93,93)">Powered by : &nbsp;Orange Technolab P Ltd</span>
										</td>
									</tr>
								</tbody>
							</table>
						</blockquote>'
						
						
						SET @Body = (
										select 
												Alpha_Emp_Code + ' - ' + Emp_Full_Name as [tdc],
												Branch_Name as [tdc],
												Desig_Name as [tdc],
												Convert(nvarchar(11),Date_Of_Join, 113)as [tdc],
												Convert(nvarchar(11),Date_of_Retirement, 113)as [tdc]	
										FROM #EMP_RETIREMENT 
										where	isnull(MANAGER_EMAIL,'') =  COALESCE(@MANAGER_EMAIL,MANAGER_EMAIL,'')
												AND IsNull(HR_EMAIL,'') =  COALESCE(@HR_EMAIL,HR_EMAIL, '')
												AND ISNULL(ACC_EMAIL,'') = COALESCE(@ACC_EMAIL,ACC_EMAIL,'')
												AND ISNULL(Other_Email,'') = COALESCE(@O_Email,Other_Email,'')
										ORDER BY Date_of_Retirement FOR XML
										raw('tr'), ELEMENTS
									)
										 
						                
						SELECT  @Body = isnull(@TableHead,'') + isnull(@Body,'') + isnull(@TableTail,'')  
						
						SET @body = REPLACE(@body, '<tdc>', '<td style="'+ @style + '">')
			           		             		  
           				Declare @subject as varchar(max)           
           				Set @subject = 'Employee Retirement Detail'
			           	
           				Declare @profile as varchar(50)
						set @profile = ''
						declare @server_link as varchar(500)
							  
						select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link  from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
						
						if isnull(@profile,'') = ''
						begin
						  select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
						end
			            
			            
						DECLARE @Body_final AS VARCHAR(MAX)
						declare @monthyear as varchar(15)
						--set @monthyear = CONVERT(CHAR(4), @ToDate, 100) + CONVERT(CHAR(4), @ToDate, 120) 
           				set @Body_final = @Body
			   			  
   						--set @Body_final = REPLACE(@Body_final ,'#Server_link#',@server_link)  
   						--set @Body_final = REPLACE(@Body_final ,'#from_date#', Convert(nvarchar(11), @FromDate, 113))  
   						--set @Body_final = REPLACE(@Body_final ,'#To_date#', Convert(nvarchar(11), @ToDate, 113))  
   						--set @Body_final = REPLACE(@Body_final ,'#cmp_Name#',@cmp_name )  
			           
					   --select @Body_final     
					   --return
			           

			           IF @TO_EMAIL_DETAIL <> ''  or @CC_EMAIL_DETAIL <> ''
						BEGIN	
						
								EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @TO_EMAIL_DETAIL, @subject = @subject, @body = @Body_final, @body_format = 'HTML',@copy_recipients = @CC_EMAIL_DETAIL,@blind_copy_recipients = ''
						END
										 
						
						fetch next from Employee_Retire into @MANAGER_EMAIL,@HR_EMAIL,@ACC_EMAIL,@O_EMAIL
					END
				   
			close Employee_Retire                    
			deallocate Employee_Retire  

END

