
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Join_Left_Reminder]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	  DECLARE @DATE VARCHAR(20)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      SET @DATE = RIGHT(CAST(GETDATE() AS DATETIME), 5)      
      
            
      IF @cmp_id_Pass = 0
		 SET @cmp_id_Pass = NULL
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
      CREATE TABLE #Temp
      ( 
		CON				INT IDENTITY(1, 1),
        Cmp_ID			NUMERIC(18,0),
		Emp_ID			NUMERIC(18,0),
		Alpha_Emp_Code	VARCHAR(100),
		Emp_Full_Name	VARCHAR(200),
		Branch_ID		NUMERIC(18,0),
		Branch_Name		VARCHAR(200),
		Dept_ID			NUMERIC(18,0),
		Dept_Name		VARCHAR(200),
		Desig_Id		NUMERIC(18,0),
		Desig_Name		VARCHAR(200),
		Join_Date		varchar(20),
		Left_Date		varchar(20),
		[Type]			VARCHAR(20),
		Cmp_Name		VARCHAR(300),
		Vertical		VARCHAR(300),
		SubVertical		VARCHAR(300),
		Left_Reason		VARCHAR(300)
      )   
           
            
	 INSERT INTO #Temp
                ( Cmp_ID,
                  Emp_ID,
                  Alpha_Emp_Code,
				  Emp_Full_Name,
				  Branch_ID,
				  Branch_Name,
				  Dept_ID,
				  Dept_Name,
				  Desig_Id,
				  Desig_Name,
				  Join_Date,
				  Left_Date,
				  [Type],
				  Cmp_Name,
				  Vertical,
				  SubVertical,
				  Left_Reason
                )
                ( 
					Select	EM.Cmp_ID,EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Branch_ID,BM.Branch_Name,
							EM.Dept_ID,ISNULL(DM.Dept_Name,'-NA-'),EM.Desig_Id,ISNULL(DEM.Desig_Name,'-NA-')
							,CONVERT(VARCHAR(20),EM.Date_Of_Join,106), '-NA-' ,'Join' as [Type],CM.Cmp_Name
							,isnull(VS.Vertical_Name,'-NA-') as Vertical
							,isnull(SV.SubVertical_Name,'-NA-') as SubVertical
							,'' as Left_Reason
					from	T0080_EMP_MASTER EM WITH (NOLOCK)
							INNER JOIN 	T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID
							INNER JOIN 
									(	
										SELECT	MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
										FROM	T0095_INCREMENT I WITH (NOLOCK)
												INNER JOIN 
															(
																SELECT	MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																WHERE	I3.Increment_effective_Date <= GETDATE()
																GROUP BY I3.EMP_ID  
															) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
									   where	I.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I.Cmp_ID = @CMP_ID_PASS
									   GROUP BY I.EMP_ID  
									) Qry on	I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
							--Inner join(
							--				select	Distinct I.Emp_Id 
							--				from	T0095_Increment I 
							--						inner join(
							--										select	max(Increment_effective_Date) as For_Date , Emp_ID 
							--										from	T0095_Increment  
							--										group by emp_ID
							--									) Qry ON I.Emp_ID = Qry.Emp_ID 
							--			) Qry1 ON EM.Emp_ID = Qry1.Emp_ID 
							Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = I.Branch_ID
							Inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id
							Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = I.Dept_ID
							Left Outer Join T0040_DESIGNATION_MASTER DEM WITH (NOLOCK) ON DEM.Desig_ID = I.Desig_Id
							LEFT OUTER JOIN T0040_Vertical_Segment AS VS WITH (NOLOCK) ON VS.Vertical_ID = I.Vertical_ID
							LEFT OUTER JOIN T0050_SubVertical AS SV WITH (NOLOCK) ON SV.SubVertical_ID = I.SubVertical_ID
					Where	CONVERT(varchar(30),EM.System_Date_Join_left,106) = CONVERT(varchar(30),GETDATE() - 1,106) 
							And Emp_Left <> 'Y' and Em.Cmp_ID= ISNULL(@cmp_id_Pass,Em.Cmp_ID)
					UNION
					Select	EM.Cmp_ID,EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Branch_ID,BM.Branch_Name,
							EM.Dept_ID,ISNULL(DM.Dept_Name,'-NA-'),EM.Desig_Id,ISNULL(DEM.Desig_Name,'-NA-')
							,CONVERT(VARCHAR(20),EM.Date_Of_Join,106),CONVERT(VARCHAR(20),LE.Left_Date,106),'Left' as [Type],CM.Cmp_Name 
							,isnull(VS.Vertical_Name,'-NA-') as Vertical
							,isnull(SV.SubVertical_Name,'-NA-') as SubVertical
							,LE.Left_Reason as Left_Reason
					from	T0100_LEFT_EMP LE WITH (NOLOCK)
							Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON LE.Emp_ID = EM.Emp_ID AND Emp_Left = 'Y'
							INNER JOIN 	T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID = I.Emp_ID
							INNER JOIN 
									(	
										SELECT	MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
										FROM	T0095_INCREMENT I WITH (NOLOCK)
												INNER JOIN 
															(
																SELECT	MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																WHERE	I3.Increment_effective_Date <= GETDATE()
																GROUP BY I3.EMP_ID  
															) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
									   where	I.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I.Cmp_ID = @CMP_ID_PASS
									   GROUP BY I.EMP_ID  
									) Qry on	I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
							--Inner join (
							--				select	Distinct I.Emp_Id 
							--				from	T0095_Increment I 
							--						inner join(
							--										select	max(Increment_effective_Date) as For_Date , Emp_ID 
							--										from	T0095_Increment  
							--										group by emp_ID
							--									) Qry ON I.Emp_ID = Qry.Emp_ID 
							--			) Qry1 ON EM.Emp_ID = Qry1.Emp_ID 
							Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = I.Branch_ID
							Inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id
							Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = I.Dept_ID
							Left Outer Join T0040_DESIGNATION_MASTER DEM WITH (NOLOCK) ON DEM.Desig_ID = I.Desig_Id
							LEFT OUTER JOIN T0040_Vertical_Segment AS VS WITH (NOLOCK) ON VS.Vertical_ID = I.Vertical_ID
							LEFT OUTER JOIN T0050_SubVertical AS SV WITH (NOLOCK) ON SV.SubVertical_ID = I.SubVertical_ID
					Where	CONVERT(varchar(30),EM.System_Date_Join_left,106) = CONVERT(varchar(30),GETDATE() -1 ,106) and  Em.Cmp_ID= ISNULL(@cmp_id_Pass,Em.Cmp_ID)
                )    

		 IF OBJECT_ID('tempdb..#Temp_Cmp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp_Cmp
         END
         
          CREATE table #Temp_Cmp
		( 
			CON INT IDENTITY(1, 1),
			Cmp_ID NUMERIC(18,0)
		)
		
		INSERT  INTO #Temp_Cmp
            ( 
				Cmp_ID
			)
            (
               Select Cmp_ID from #Temp group by #Temp.Cmp_ID
            )
            
            
      DECLARE @Cmp_ID AS NUMERIC(18, 0)  
      DECLARE @Cmp_Name AS varchar(250)    
	  SET @Cmp_ID = 0 
	  SET @Cmp_Name = ''
	  
      Declare @current_Date as Datetime
      set @current_Date = GETDATE()
      
      
      DECLARE @I INT       
      SET @I = 1                      
      DECLARE @COUNT INT       
      SELECT    @COUNT = COUNT(CON)
      FROM      #Temp_Cmp    
            
      WHILE ( @I <= @COUNT ) 
         BEGIN         
                  SELECT    @Cmp_ID = Cmp_ID
                  FROM      #Temp_Cmp
                  WHERE     CON = @I 
        
				 SET @Cmp_Name = (Select TOP 1 Cmp_Name From #Temp where Cmp_ID = @Cmp_ID)
					
           			  Declare @profile as varchar(50)
					  Declare @Server_link as varchar(500)
					  Declare @Profile_Email as varchar(Max)
					  set @Server_link =''
       				  set @profile = ''
       				  set @Profile_Email = ''
       					  
       				  select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile where cmp_id = @Cmp_Id
       					         					  
       				  if isnull(@profile,'') = ''
       				     begin
       					   select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile where cmp_id = 0       					   
       				     end 
       				     
       				 Declare @HREmail_ID nvarchar(4000)
       				 Declare @HREmp_Name nvarchar(400)
					 Select @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Is_HR = 1)
					 Select @HREmp_Name =(Select Emp_Full_Name From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in (SELECT TOP 1 Emp_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID= @Cmp_Id AND Is_HR = 1 ))
  		  
				  Declare  @TableHead varchar(max),
				  @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
									  '<style>' +
									  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
									  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear All, </div>	<br/>					
								  								  
								  <table width="850" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="8" align="center" valign="middle" colspan="2" ></td>
										</tr>
									  <tr>
										<td colspan="2" width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Employee JOIN/LEFT Records.</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle" colspan="2"></td>
										  </tr>
										  <tr>
											<td colspan="2" width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">
											 <a href="' + @Server_link + '" style="text-decoration: bold;">
												<div align="center" class="White" style="padding-left: 40px">
                                                click here for login to payroll Hrms </div></a>
											
											</td>
										  </tr>
										  <tr>
											<td height="4" align="center" valign="middle" colspan="2"></td>
										  </tr>
										  <tr>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 0px 0px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: left; font-size: 12px; padding-left:20px;border-right:none;"><b>'+ @Cmp_Name +'</b></td>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 0px 10px 10px 0px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: right; font-size: 12px; padding-right:20px;border-left:none;"><b>'+ CONVERT(varchar(20),GETDATE() - 1,106) +'</b></td>
										  </tr>
										   <tr>
											<td height="4" align="center" valign="middle" colspan="2"></td>
										  </tr>
								  </table>                                    
								  <table width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: bold; text-align: center;
									font-size: 12px;"><tr>' +
										  '<td bgcolor=#FFFFFF align=center><b>Employee Code</b></td>' +
										  '<td align=center><b>Employee Name</b></td>' +
										  '<td align=center><b>Branch Name</b></td>' +
										  '<td align=center><b>Designation</b></td>' +
										  '<td align=center><b>Department</b></td>' +	
										  '<td align=center><b>Vertical</b></td>' + 
										  '<td align=center><b>Sub Vertical</b></td>' +
										  '<td align=center><b>Join Date</b></td>' + 	                  
										  '<td align=center><b>Left Date</b></td>' + 
										  '<td align=center><b>Type</b></td>' +
										  '<td align=center><b>Left Reason</b></td></tr>'
										                                     
                  SET @TableTail = '</table></td></tr></table></body></html>';   
                  

                  
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										Alpha_Emp_Code  as [TD],
										Emp_Full_Name  as [TD],
										Branch_Name  as [TD],
										Desig_Name  as [TD],
										Dept_Name  as [TD],
										Vertical AS [TD],
										SubVertical AS [TD],
										Join_Date As [TD],
										Left_Date as [TD],										
										Type as [TD],
										Left_Reason as [TD]
                                FROM    #Temp where Cmp_ID = @Cmp_ID
                                ORDER BY  Alpha_Emp_Code For XML raw('tr'), ELEMENTS) 
				  
				  Set @Body = replace(@Body,'<td>','<td align=''left''>')
           		  SELECT  @Body = @TableHead + @Body + @TableTail 
           		 
           		 
           		  DECLARE @EmailNotification AS NUMERIC
                  set @EmailNotification = 1
                  IF @EmailNotification = 1 
                     BEGIN		
			
                            EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Profile_Email, @subject = 'Employee JOIN/LEFT Records.', @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email 
            
					 END      
					
			  SELECT @I = @I + 1   
		END                  
End

