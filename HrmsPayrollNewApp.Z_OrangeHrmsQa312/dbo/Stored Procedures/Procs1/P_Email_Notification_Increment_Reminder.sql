
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Email_Notification_Increment_Reminder]
	@CMP_ID_PASS Numeric,
	@CC_Email varchar(200) = ''
	--@Notification_Year Varchar(20),
	--@Notification_Subject Varchar(200) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Object_ID('tempdb..#EmpData') is not null
		Begin
			Drop Table #EmpData
		End

	Create Table #EmpData
	(
		Cmp_ID Numeric,
		Emp_ID Numeric,
		Alpha_Emp_Code Varchar(50),
		Emp_Name Varchar(300),
		Desig_Name Varchar(100),
		Cost_Center Varchar(100),
		Date_of_join Datetime,
		Next_Increment_Date varchar(20),
		Sort_id Numeric(18,0)
	)

	Declare @For_Date date
	Set @For_Date = Getdate()--DateAdd(MM,1,Getdate())

		Begin

			Set language british

			declare @Days as Numeric(18,0)
			select	@Days = Setting_Value 
			from	T0040_SETTING WITH (NOLOCK)
			where	cmp_Id = @CMP_ID_PASS and Setting_Name = 'Send Remainder mail of Increment'

			Declare @From_Date datetime
			Declare @To_Date Datetime

			Set @From_Date = CONVERT(date, Getdate(), 103)
			Set @To_Date = Dateadd(dd,@Days,CONVERT(date, Getdate(), 103))
			
			Insert into #EmpData(Cmp_ID,Emp_ID,Alpha_Emp_Code,Emp_Name,Desig_Name,Cost_Center,Date_of_join,Next_Increment_Date,Sort_id)
			
				Select	EM.Cmp_ID,EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,DM.Desig_Name,Isnull(CC.Center_Name,'') as Center_Name,date_of_join,
					ECO.Value as Next_Increment_Date
					,0 as Sort_id	
			From	T0080_EMP_MASTER EM WITH (NOLOCK)
					Inner Join (
								Select	I.Emp_ID,I.Segment_ID,I.Branch_ID,I.Grd_ID,I.Desig_Id,I.Center_ID 
								From	T0095_Increment I WITH (NOLOCK)
										Inner Join	(
														select Max(TI.Increment_ID) as Increment_Id,TI.Emp_ID
															from t0095_increment TI WITH (NOLOCK) inner join
															(
																Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
																	from T0095_Increment WITH (NOLOCK)
																Where Increment_effective_Date <= @For_Date And Cmp_ID = @CMP_ID_PASS
																GROUP BY Emp_ID 
															) new_inc on Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date and TI.Emp_ID = new_inc.Emp_ID
														Where TI.Increment_effective_Date <= @For_Date
														GROUP BY TI.Emp_ID
													)  as Qry ON I.Increment_ID = Qry.Increment_Id AND I.Emp_ID = Qry.Emp_ID
								) as Qry1 ON Qry1.Emp_ID =EM.Emp_ID			
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = Qry1.Desig_Id
					LEFT OUTER JOIN T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.Center_ID = Qry1.Center_ID
					Inner JOin	T0081_CUSTOMIZED_COLUMN CO WITH (NOLOCK) On CO.CMp_Id = EM.Cmp_Id
					Inner JOin	T0082_Emp_Column ECO WITH (NOLOCK) On ECO.Emp_Id = EM.Emp_Id ANd Co.Tran_Id = ECO.mst_Tran_Id And isdate(ECO.Value) = 1
			Where	CONVERT(datetime, ECO.Value, 103) between @From_Date and @To_Date and 
					 EM.Cmp_ID = @CMP_ID_PASS and 
					 (EM.Emp_Left = 'N' or EM.Emp_Left_Date is null) AND
					 CO.Column_Name = 'Next Increment Date'
					
			order by Next_Increment_Date,Emp_ID
		End
	
	

	DECLARE @style VARCHAR(max)
	SET @style = 'text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';

	DECLARE @TableHead VARCHAR(max),@TableTail VARCHAR(max)  

	SET @TableHead = '<html><head>
			<style>
					td {font-family: arial,sans-serif;font-size: 13px;}
					span{font-family: arial,sans-serif;font-size: 15px;color: red;font-weight: 700;}
			</style>
			</head>
			<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
				padding-left: 1ex">
				<table style="background-color: #edf7fd; border-collapse: collapse;"
					align="center" cellpadding="5px" width="100%">
					<tbody>
						<tr>
							<td colspan="6">
								Hello,
							</td>
						</tr>
						<tr>
							<td colspan="6"> 
								Please check Below details of Increment
							</td>
						</tr>
						<tr>
							<td colspan="6">
								<table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="3"  border="1px"
									cellspacing="0" width="100%">
									<tbody>
										<tr>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" width="15%">
												<b>Employee Code</b>
											</td>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" width="25%">
												<b>Employee Name</b>
											</td>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" nowrap="" width="15%">
												<b>Designation</b>
											</td>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" nowrap="" width="15%">
												<b>Cost Center</b>
											</td>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" nowrap="" width="15%">
												<b>Date of Joining</b>
											</td>
											<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
												align="center" nowrap="" width="15%">
												<b>Next Increment Date</b>
											</td>
										</tr>'
	SET @TableTail = '</tbody>
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
						</tbody>
				</table>
			</blockquote>
			</html>'

	DECLARE @Body AS VARCHAR(MAX)
		SET @Body = ( SELECT  
								Cast(Alpha_Emp_code AS VARCHAR(50)) AS [TD],
								Emp_Name  AS [TD],	
								Desig_Name  AS [TD],
								Cost_Center  AS [TD],								
								IsNull(CONVERT(VARCHAR(12),Date_of_join, 103),'') AS [TD],
								Next_Increment_Date  AS [TD]
                        FROM    #EmpData
                        ORDER BY  Sort_id 
						For XML raw('tr'),ELEMENTS) 
       
	SET  @Body = @TableHead + @Body + @TableTail    		  
	--SET @Body = REPLACE(@Body, '<td>', '<td style="'+ @style + '">')
	Set @Body = REPLACE(@Body,'&lt;span&gt;','<span>')
	Set @Body = REPLACE(@Body,'&lt;/span&gt;','</span>')

	
	
	DECLARE @HREmail_ID	NVARCHAR(4000)
	SELECT @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@CMP_ID_PASS AND Is_HR = 1)

	DECLARE @profile AS VARCHAR(50)
    SET @profile = ''

	SELECT @profile = IsNull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @CMP_ID_PASS
       					  
    IF IsNull(@profile,'') = ''
       	BEGIN
       		SELECT @profile = IsNull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       	END 

	IF @HREmail_ID <> '' And @Body <> ''
		Begin
			EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Increment Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @CC_Email                                                                             
		End
	Set language English
END 

