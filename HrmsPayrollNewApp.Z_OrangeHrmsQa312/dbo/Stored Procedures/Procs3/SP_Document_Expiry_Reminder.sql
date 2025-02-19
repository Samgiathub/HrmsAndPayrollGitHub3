


-- =============================================
-- Author:		<Mukti>
-- Create date: <17-01-2018>
-- Description:	<Send Email Reminder-employee of Passport/Visa/Licence Expiry Details>
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Document_Expiry_Reminder]
@CMP_ID_PASS NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	DECLARE @DATE VARCHAR(11)   
    DECLARE @APPROVAL_DAY AS NUMERIC    
    DECLARE @REMINDERTEMPLATE AS NVARCHAR(4000)
    SET @DATE = CAST(GETDATE() AS varchar(11))
       
    if @cmp_id_Pass = 0
		set @cmp_id_Pass=null
      
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE table #Temp (
		--Row_No Numeric,
		Cmp_Id Numeric,
		Emp_Id numeric,
		Emp_Name varchar(200),
		Branch_name varchar(100),
		Document_Type varchar(100),
		ExpiryDate Datetime,		
		Dept_Name Varchar(200),
		Tran_ID	NUMERIC
	 )
 
	
   IF OBJECT_ID('tempdb..#HR_Email') IS NOT NULL 
      BEGIN
         DROP TABLE #HR_Email
      END

   CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

	Insert Into #HR_Email (Cmp_ID)
	SELECT Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK) 

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	Declare @Document_Expiry_Days as Numeric
	
	CREATE table #Emp_Cons 
	(
		Emp_ID	NUMERIC,
		Branch_Id numeric,
		Dept_ID NUMERIC
	);	
							  
	--select * from #HR_Email
	
	declare Cur_Company cursor for 
	select Cmp_Id from #HR_Email where Cmp_ID=@CMP_ID_PASS order by Cmp_ID 
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin
			Select @Document_Expiry_Days = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Reminder Days for Document Expiry'   				
					
			INSERT INTO #Emp_Cons(Emp_ID,Branch_Id,Dept_ID)
			SELECT I.Emp_Id,I.Branch_ID,I.Dept_ID 
				FROM T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
									FROM T0095_Increment I2 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
													FROM	T0095_INCREMENT I3 WITH (NOLOCK)
													WHERE	I3.Increment_Effective_Date <= GETDATE()
													GROUP BY I3.Emp_ID
													) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
									GROUP BY i2.emp_ID 
								) Qry 
					ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID				  
			WHERE Cmp_ID = @Cmp_ID 
	
		Insert into #Temp	
		Select ECD.Cmp_ID,ECD.Emp_ID,
		EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,'Passport',Ecd.Imm_Date_of_Expiry,DM.Dept_Name,ECD.Row_ID 			
		from T0090_EMP_IMMIGRATION_DETAIL ECD  WITH (NOLOCK)
			inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
			inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
			inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
			inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
		Where   ECD.Imm_Date_of_Expiry between  GETDATE() and DateAdd(DAY,@Document_Expiry_Days,Getdate())    
		And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Passport'
		
		Insert into #Temp
		Select ECD.Cmp_ID,ECD.Emp_ID,
		EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,'Visa',Ecd.Imm_Date_of_Expiry,DM.Dept_Name,ECD.Row_ID  			 
		from T0090_EMP_IMMIGRATION_DETAIL ECD WITH (NOLOCK) 
			inner join t0080_Emp_Master EM WITH (NOLOCK) on ECD.Emp_ID=EM.Emp_ID 
			inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
			inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
			inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
		Where   ECD.Imm_Date_of_Expiry between  GETDATE() and DateAdd(DAY,@Document_Expiry_Days,Getdate())    
		And ECD.Cmp_ID= @CMP_ID and ECD.Imm_Type='Visa'
		
		Insert into #Temp
		Select ECD.Cmp_ID,ECD.Emp_ID,
		EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name as Emp_Full_Name,BM.Branch_Name,LM.Lic_Name,Ecd.Lic_End_Date,DM.Dept_Name,ECD.Row_ID  			 
		from T0090_EMP_LICENSE_DETAIL ECD WITH (NOLOCK) 
			inner join t0080_Emp_Master EM WITH (NOLOCK) on   ECD.Emp_ID=EM.Emp_ID 
			inner join #Emp_Cons I ON EM.Emp_ID=I.Emp_ID 
			inner join T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID 
			inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) On I.Dept_ID = DM.Dept_Id 
			inner JOIN T0040_LICENSE_MASTER LM WITH (NOLOCK) on ECD.LIC_ID=LM.Lic_ID
		Where   ECD.Lic_End_Date between  GETDATE() and DateAdd(DAY,@Document_Expiry_Days,Getdate())    
		And ECD.Cmp_ID= @CMP_ID 
		
		--select * from #Temp
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1	
			if isnull(@HREmail_ID,'')='' 
			begin
				select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
			end

			Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id		
			
           				declare @style varchar(max)
           				Declare @TableHead varchar(max),@TableTail varchar(max),@TableHead1 varchar(max),@TableHead2 varchar(max),@TableTr varchar(500),@Tableclose varchar(500)
           				DECLARE @Body AS VARCHAR(MAX)
           				DECLARE @Body1 AS VARCHAR(MAX)
           				
						set @style = 'text-align:center;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';
												    	 
						set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; padding-left: 1ex">
							<style> 
							.new {text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff}   
  							</style>
						  
							<table style="background-color: #edf7fd; border: 1px solid #b0daff"
								align="center" cellpadding="5px" width="100%">
								<tbody>       
									<tr>
										<td colspan="9">
											Please Verify Document Expiry Details.
										</td>
									</tr>
									<tr>
										<td colspan="9">
											&nbsp;
										</td>
									</tr>'
					     set @TableHead1 = '<tr>
										    <td colspan="10">
											  <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
												cellspacing="0" width="100%">
												<tbody>
													<tr>
														<th colspan="10" style="color: #3f628e; font-weight: bold" align="left">
															Employees Document Expiry Details:
														</th>
													</tr>
													<tr>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:5%"
															align="left">
															<b>Sr.No</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:27%"
															align="left">
															<b>Employee Name</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="left">
															<b>Branch</b>
														</td>	
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="left">
															<b>Department</b>
														</td>													
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="left">
															<b>Document Type</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:15%"
															align="left">
															<b>Expiry Date</b>
														</td>
														<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:5%"
															align="left">
															<b>Days</b>
														</td>
													</tr>'
						
									set @TableTail = '
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
						
						
						Set @Tableclose = '</tbody>
											</table>
										</td>
									</tr>'
						SET @Body = (
										
										SELECT  
										ROW_NUMBER() OVER(ORDER BY Tran_ID) as [TD],
										Emp_Name  as [TD],
										Isnull(Branch_name,'-') as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Document_Type,'-') as [TD],
										Convert(nvarchar(11), ExpiryDate, 113) As [TD],
										DATEDIFF(dd,GETDATE(),ExpiryDate) AS [TD]
										FROM    #Temp
										WHERE   Cmp_ID = @Cmp_Id   For XML raw('tr'), ELEMENTS
									)
															
						     -- print @Body          
						SELECT  @Body = isnull(@TableHead,'') + isnull(@TableHead1,'') + isnull(@Body,'') + ISNULL(@Tableclose,'') + isnull(@TableTail,'')  
						
						SET @body = REPLACE(@body, '<tdc>', '<td style="'+ @style + '">')
			           		             		  
           				Declare @subject as varchar(max)           
           				Set @subject = 'Document Expiry(' + Convert(nvarchar(11), @DATE, 113)  + ')'
			           	
           				Declare @profile as varchar(50)
       					set @profile = ''
       					  
       					select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					if isnull(@profile,'') = ''
       					  begin
       						select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           	select * from #Temp
           	--select @HREmail_ID,@profile,@Body,@CC_Email
           	--select @Body
           		if  (@ECount>0)
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
					
					
					Set @HREmail_ID = ''
					Set @HR_Name = ''
					Set @ECount = 0
					
					--Select DATEDIFF(dd,GETDATE(),ExpiryDate), * From #Temp
			
			 Delete FROM #Temp
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         
	
End



