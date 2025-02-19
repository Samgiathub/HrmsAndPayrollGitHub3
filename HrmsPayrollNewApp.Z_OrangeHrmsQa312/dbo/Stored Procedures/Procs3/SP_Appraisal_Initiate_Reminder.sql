


-- =============================================
-- Author:		<Mukti>
-- Create date: <20-04-2018>
-- Description:	<Send Email Reminder-Appraisal/KPA Initiation>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Appraisal_Initiate_Reminder]
@CMP_ID_PASS NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = ''
AS 
BEGIN   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @DATE VARCHAR(11)   
    SET @DATE = CAST(GETDATE() AS VARCHAR(11))
       
    if @cmp_id_Pass = 0
		set @cmp_id_Pass=null
  
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
	Declare @Emp_Name as VARCHAR(250)
	DECLARE @Enddate as DATETIME
	DECLARE @email_id as VARCHAR(150)
	DECLARE @initiate_type as VARCHAR(15)
	DECLARE @KPA_ALIAS as VARCHAR(25)
	DECLARE @form_name as VARCHAR(50)
	
	CREATE table #Emp_details 
	(
		Emp_ID	NUMERIC,
		Emp_Name varchar(250),
		Startdate DATETIME,
		Enddate	DATETIME,
		email_id VARCHAR(150),
		initiate_type varchar(15)
	);	
							  
	--select * from #HR_Email
	
	declare Cur_Company cursor for 
	select Cmp_Id from #HR_Email where Cmp_ID=@CMP_ID_PASS order by Cmp_ID 
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin		
			SELECT @KPA_ALIAS = UPPER(ALIAS) FROM T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Caption = 'KPA'
		
			INSERT INTO #Emp_details(Emp_ID,Emp_Name,Startdate,Enddate,email_id,initiate_type)
			SELECT HA.Emp_Id,EM.Emp_Full_Name,HA.SA_Startdate,HA.SA_Enddate,EM.Work_Email,'Appraisal'
			from T0050_HRMS_InitiateAppraisal HA WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) on HA.Emp_Id=EM.Emp_ID
			--INNER JOIN T0095_Increment I on HA.Emp_Id=I.Emp_ID
			--INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID,i2.Emp_ID  
			--						FROM T0095_Increment I2
			--							INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
			--										FROM	T0095_INCREMENT I3 
			--										WHERE	I3.Increment_Effective_Date <= GETDATE()
			--										GROUP BY I3.Emp_ID
			--										) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
			--						GROUP BY i2.emp_ID 
			--					) Qry 
			--		ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID				  
			WHERE HA.Cmp_ID = @Cmp_ID and (HA.SA_Startdate <= CONVERT(varchar(10),GETDATE(),120) 
			and HA.SA_Enddate >= CONVERT(varchar(10),GETDATE(),120)) and HA.SA_Status <> 1
	
			INSERT INTO #Emp_details(Emp_ID,Emp_Name,Startdate,Enddate,email_id,initiate_type)
			SELECT HA.Emp_Id,EM.Emp_Full_Name,HA.KPA_StartDate,HA.KPA_EndDate,EM.Work_Email,'KPA'
			from T0055_Hrms_Initiate_KPASetting HA WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) on HA.Emp_Id=EM.Emp_ID
			WHERE HA.Cmp_ID = @Cmp_ID and (HA.KPA_StartDate <= CONVERT(varchar(10),GETDATE(),120) 
			and HA.KPA_EndDate >= CONVERT(varchar(10),GETDATE(),120)) and HA.Initiate_Status <> 1
			
	select * from #Emp_details
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1	
			if isnull(@HREmail_ID,'')='' 
			begin
				select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
			end

			declare Cur_Emp cursor for 
			select Emp_Name,Enddate,email_id,initiate_type from #Emp_details 
			open Cur_Emp                      
			fetch next from Cur_Emp into @Emp_Name,@Enddate,@email_id,@initiate_type
			while @@fetch_status = 0                    
				begin	
						--select CONVERT(VARCHAR(25),@Enddate,103)
           				DECLARE @style VARCHAR(max)
           				Declare @TableHead varchar(max),@TableTail varchar(max),@TableHead1 varchar(max),@TableHead2 varchar(max),@TableTr varchar(500),@Tableclose varchar(500)
           				DECLARE @Body AS VARCHAR(MAX)
           				DECLARE @Body1 AS VARCHAR(MAX)
           				
						set @style = 'text-align:center;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';
							
						IF @initiate_type = 'Appraisal'
							BEGIN 					    	 
								set @form_name='Self Assessment Form'
							END
						else	
							BEGIN
								set @form_name='Employee Goal Setting'
							END
							
								set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; padding-left: 1ex">
									<style> 
									.new {text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff}   
  									</style>
								  
									<table style="background-color: #edf7fd; border: 1px solid #b0daff"
										align="center" cellpadding="5px" width="100%">
										<tbody>       
											<tr>
												<td colspan="9">
													
												</td>
											</tr>
											<tr>
												<td colspan="9" style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e;width:5%;padding-left: 10px">
													<b> ' + @form_name + ' </b>
												</td>
											</tr>'
								 set @TableHead1 = '<tr>
													<td colspan="10">
													  <table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
														cellspacing="0" width="100%">
														<tbody>													
															<tr>
																<td	align="left">
																	Dear  ' + @Emp_Name +',															
																</td>														
															</tr>
															<tr><td style="height:10px"></td></tr>
															<tr>
																<td align="left">															
																	Your ' + @form_name + ' has been initiated, 
																	kindly fill and submit online Form before '+ cast(CONVERT(VARCHAR(25),@Enddate,103) as VARCHAR(25)) +'.
																	It is strongly recommended that you submit well before the last submission date in order to enable a timely appraisal process.																	
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
						        
						SELECT  @Body = isnull(@TableHead,'') + isnull(@TableHead1,'') + ISNULL(@Tableclose,'') + isnull(@TableTail,'')  
						
						SET @body = REPLACE(@body, '<tdc>', '<td style="'+ @style + '">')
			           		 PRINT @body            		  
           				Declare @subject as varchar(max)           
           				Set @subject = @form_name +' Initiated'
			           	
           				Declare @profile as varchar(50)
       					set @profile = ''
       					  
       					select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id

						if @email_id <> ''
							set @email_id=@email_id + ',' + @HREmail_ID
       					ELSE
       						set @email_id=@HREmail_ID 
       						
       						PRINT @email_id 
       					if isnull(@profile,'') = ''
       					  begin
       						select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
						--select @email_id,@profile,@Body,@CC_Email
           				EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @email_id, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
					
				 fetch next from Cur_Emp into @Emp_Name,@Enddate,@email_id,@initiate_type
			   end                    
			close Cur_Emp                    
			deallocate Cur_Emp 
					
			Set @HREmail_ID = ''
			Set @HR_Name = ''
							
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         
	
End



