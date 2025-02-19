--EXEC [SP_Employee_BirthDay_EMail_Test] 121,'yogesh.p@orangewebtech.com'
--EXEC P_BIRTHDAY_UTILITY
CREATE PROCEDURE [dbo].[SP_Employee_BirthDay_EMail_Test]

@CMP_ID NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = ''

AS

DECLARE @PROFILE_CMP_ID AS INT
SET @PROFILE_CMP_ID=0

	DECLARE @DATE AS VARCHAR(MAX) = ''	
	IF @DATE = ''
	 SET @DATE = GETDATE()

     IF OBJECT_ID('TEMPDB..#TBL_EMP_DATA') IS NOT NULL 
         BEGIN
               DROP TABLE #TBL_EMP_DATA
         END
         
	SELECT	
	
	--CM.CMP_EMAIL AS CMP_EMAIL
	--,CM.CMP_SIGNATURE AS CMP_SIGNATURE,
	--		CASE WHEN ISNULL(IMAGE_FILE_PATH,'') = '' 
	--			THEN '' 
	--			ELSE RIGHT(CM.IMAGE_FILE_PATH,LEN(CM.IMAGE_FILE_PATH)-(CHARINDEX('CMPIMAGES',CM.IMAGE_FILE_PATH)+9))
	--		END AS IMAGE_FILE_PATH,
			--CM.CMP_ID AS CMP_ID,EM.EMP_ID AS EMP_ID,CMP_NAME,
	        EMP_FULL_NAME,WORK_EMAIL,BRANCH_NAME,Desig_Name,
			CONVERT(VARCHAR(7), CASE WHEN ISNULL(ACTUAL_DATE_OF_BIRTH,'') = '' THEN  DATE_OF_BIRTH ELSE ACTUAL_DATE_OF_BIRTH END , 6)AS DATE_OF_BIRTH1,Date_Of_Birth,Em.Image_Name as Emp_Image,cm.Image_file_Path as Cmp_Img_Path,cm.Image_name as Cmp_Image_Name,cm.Cmp_Name
			--EMAIL_SIGNATURE,EMAIL_ATTACHMENT,
			--CASE WHEN (ISNULL(EM.IMAGE_NAME,'')<>'' AND ISNULL(EM.IMAGE_NAME,'') <> '0.JPG') 
			--	THEN EM.IMAGE_NAME 
			--	ELSE  
			--		CASE WHEN EM.GENDER = 'F' 
			--			THEN 'EMP_DEFAULT_FEMALE.PNG' 
			--			ELSE 'EMP_DEFAULT.PNG' 
			--		END 
			--END AS IMAGE_NAME ,BM.BRANCH_NAME,DM.DEPT_NAME,DSM.DESIG_NAME,MOBILE_NO
	INTO #TBL_EMP_DATA
	FROM T0080_EMP_MASTER EM 
	INNER JOIN T0095_INCREMENT I ON EM.INCREMENT_ID = I.INCREMENT_ID 
	LEFT JOIN T0030_BRANCH_MASTER BM ON I.BRANCH_ID = BM.BRANCH_ID 
	--LEFT JOIN T0040_DEPARTMENT_MASTER DM ON I.DEPT_ID = DM.DEPT_ID 
	LEFT JOIN T0040_DESIGNATION_MASTER DSM ON I.DESIG_ID = DSM.DESIG_ID 
	LEFT JOIN T0010_COMPANY_MASTER AS CM ON EM.CMP_ID = CM.CMP_ID   
	--LEFT OUTER JOIN  T0010_EMAIL_FORMAT_SETTING AS EFS ON CM.CMP_ID=EFS.CMP_ID
	--LEFT OUTER JOIN T0040_EMAIL_NOTIFICATION_CONFIG ENC ON ENC.CMP_ID = CM.CMP_ID AND  EFS.EMAIL_TYPE = ENC.EMAIL_TYPE_NAME
	WHERE 
		1 = (CASE WHEN ACTUAL_DATE_OF_BIRTH IS NOT NULL AND MONTH(ACTUAL_DATE_OF_BIRTH)= MONTH(@DATE) AND DAY(ACTUAL_DATE_OF_BIRTH) = DAY(@DATE) AND ACTUAL_DATE_OF_BIRTH <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  WHEN  DATE_OF_BIRTH IS NOT NULL AND MONTH(DATE_OF_BIRTH)=MONTH(@DATE) AND DAY(DATE_OF_BIRTH) = DAY(@DATE) AND ACTUAL_DATE_OF_BIRTH IS NULL AND DATE_OF_BIRTH <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  ELSE 0 
			  END
			 )
	AND (ISNULL(EMP_LEFT,'N') <> 'Y' OR EM.EMP_LEFT_DATE IS NULL) 	
   AND EM.CMP_ID =@CMP_ID
   

   --Select * From #TBL_EMP_DATA
   --RETURN

   
DECLARE @EMP_NAME AS VARCHAR(200)	
DECLARE @WORK_EMAIL AS VARCHAR(200)
DECLARE @BRANCH_NAME AS VARCHAR(200)
DECLARE @DESIG_NAME AS VARCHAR(200)
DECLARE @DOB AS VARCHAR(200)
DECLARE @Emp_Image_Name AS VARCHAR(200)
DECLARE @Cmp_Image_Name AS VARCHAR(200)
DECLARE @Cmp_Image_Path AS VARCHAR(200)
DECLARE @Cmp_Name AS VARCHAR(200)


DECLARE CUR_EMPLOYEE CURSOR FOR     
	SELECT EMP_FULL_NAME,WORK_EMAIL,Branch_Name,Desig_Name,Date_Of_Birth,Emp_Image,Cmp_Img_Path,Cmp_Image_Name,Cmp_Name FROM #TBL_EMP_DATA ORDER BY EMP_FULL_NAME
	
	OPEN CUR_EMPLOYEE                      
	FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_NAME,@WORK_EMAIL,@BRANCH_NAME,@DESIG_NAME,@DOB,@Emp_Image_Name,@Cmp_Image_Path,@Cmp_Image_Name,@cmp_name
	WHILE @@FETCH_STATUS = 0                    
		BEGIN
			
---SET @EMP_NAME= 'RAMESH J SHAH'
		
							
					--select CONCAT_WS('/',@cmp_Image_Path ,  @Cmp_Image_Name)
					--select  @cmp_Image_Path
					--return
			
			--EXEC [SP_Employee_BirthDay_EMail_Test] 121,'Yogseh.p@orangewebtech.com'

		      DECLARE  @TABLEHEAD VARCHAR(MAX),
					   @TABLEBODY VARCHAR(MAX)   
     --      		 
					set @TABLEBODY=(Select Email_Signature from T0010_Email_Format_Setting where Cmp_ID=@CMP_ID and Email_Type='Birth Day')
					--set @TABLEBODY='<html xmlns="http://www.w3.org/1999/xhtml">  <head>  </head><div>      <table style="width: 51%">          <tbody>              <tr>                  <td style="background-color: #ffefef; width: 70%; height: 500px" valign="top">                      <table style="width: 100%">                          <tbody>                              <tr>                                  <td valign="top">                                      <table style="width: 100%">                                          <tbody>                                              <tr>                                                  <td align="left" style="font-family: Brush Script MT; font-size: 36px; text-shadow: rgb(3, 3, 3) -4px 4px 4px;                                                      font-weight: bold; padding-top: 18px; padding-left: 14px">                                                      Birthday Wishes                                                  </td>                                                  <td align="right" style="padding-right: 10px; padding-top: 12px">                                                      <img alt="Company Logo " src="http://192.168.1.200:312/App_File/Cmpimages/1_demo.PNG" style="width: 100PX" />                                                  </td>                                              </tr>                                          </tbody>                                      </table>                                  </td>                              </tr>                              <tr>                                  <td style="width: 100%">                                      <table style="width: 100%">                                          <tbody>                                              <tr>                                                  <td align="center" style="padding-top: 30px">                                                      <table style="width: 100%">                                                          <tbody>                                                              <tr>                                                                  <td align="center">                                                                      <b>#EmpName#</b>                                                                  </td>                                                              </tr>                                                              <tr>                                                                  <td align="center" valign="top">                                                                      <img alt="" src="#Emp_Image#" style="height: 170px; width: 132px; border-width: 0px;" />                                                                  </td>                                                              </tr>                                                              <tr>                                                                  <td align="center">                                                                      <b>Date Of Birth :#Date_Of_Birth#</b><br />                                                                      <b>Branch Name :#Branch_Name#</b><br />                                                                  </td>                                                              </tr>                                                              <tr>                                                                  <td>                                                                      <table style="width: 100%">                                                                          <tbody>                                                                              <tr>                                                                                  <td align="left">                                                                                      <div align="left" style="margin-left: -12px; margin-bottom: -13px">                                                                                          <img alt="" src="#Image#" style="width: 250px" /></div>                                                                                  </td>                                                                                  <td align="right" style="font-size: 36px; font-family: Brush Script MT; padding-right: 25px">                                                                                      Wishing you<br />                                                                                      a Very<br />                                                                                      Happy Birthday                                                                                  </td>                                                                              </tr>                                                                          </tbody>                                                                      </table>                                                                  </td>                                                              </tr>                                                          </tbody>                                                      </table>                                                  </td>                                              </tr>                                          </tbody>                                      </table>                                  </td>                              </tr>                          </tbody>                      </table>                  </td>              </tr>          </tbody>      </table>  </div>  </html>'

					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#EmpName#', @EMP_NAME))
					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Date_Of_Birth#',(FORMAT(Cast( @DOB aS date), 'dd MMM') )))
					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Branch_Name#', @BRANCH_NAME))
					--set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Logo#','https://lh6.googleusercontent.com/FF4xMtzyh60Lwi_jFw2xjBmZMRnaI5StF6g0YCX0L2ZRJyzWkjS6gtmoKuVzxME0-5Y=w2400'))
					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Cmp_Name#',@Cmp_Name))
					--set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Emp_Image#','https://lh5.googleusercontent.com/6Oi5VfFVtfd2VfwPw1ruPrcH9aJ47IvBjH4cd42CTZa4wJVMOFp9IFjKogU5IzDfjE4=w2400'))
					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Emp_Image#','https://www.gifcen.com/wp-content/uploads/2021/04/happy-birthday-gif-8.gif'))
					set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Designation#',@DESIG_NAME))
					--'https://lh3.googleusercontent.com/ZoFqwhf1YTdBSomraE3W73RcraPHMX2z1sQa0bXE5q6I0EamImm6UJ57eiLend8ZR-M=w2400'))
					
					--set @TABLEBODY=(SELECT REPLACE(@TABLEBODY, '#Image#','https://lh5.googleusercontent.com/6Oi5VfFVtfd2VfwPw1ruPrcH9aJ47IvBjH4cd42CTZa4wJVMOFp9IFjKogU5IzDfjE4=w2400'))

					

					 SET @TABLEHEAD = @TABLEBODY
					--<P> STYLE="COLOR:#FF8C00;">HR TEAM</P>
					 --<H3> STYLE="COLOR:#FF8C00;">HR TEAM</H1>                    
					--SET @TABLETAIL = '</BODY></HTML>';     
					          	
                  DECLARE @BODY AS VARCHAR(MAX)
                  SELECT  @BODY = @TABLEHEAD + ISNULL(@BODY,'') --+ @TABLETAIL  
           		  
           		
           		  DECLARE @SUBJECT AS VARCHAR(100)           
           		  SET @SUBJECT = 'Birthday Wishes from OTL'
			
			
			
			
				    DECLARE @PROFILE AS VARCHAR(50)
       					  SET @PROFILE = ''
       					  SELECT Distinct @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WHERE CMP_ID = @PROFILE_CMP_ID
       					  
			  IF ISNULL(@PROFILE,'') = ''
			   IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WHERE CMP_ID = @CMP_ID
			  END
			--select @PROFILE as 'PROFILE'
			  IF ISNULL(@PROFILE,'') <> ''
			  BEGIN
			  --select   @PROFILE, @WORK_EMAIL,  @SUBJECT,  @BODY,  'HTML', @CC_EMAIL
				 EXEC MSDB.DBO.SP_SEND_DBMAIL @PROFILE_NAME = 'Db_Mail_121', @RECIPIENTS = @WORK_EMAIL, @SUBJECT = @SUBJECT, @BODY = @BODY, @BODY_FORMAT = 'HTML',@COPY_RECIPIENTS = @CC_EMAIL
			  END
				 
			--EXEC [SP_Employee_BirthDay_EMail_Test] 121,'Yogesh.p@orangewebtech.com'
			SET @EMP_NAME = ''
			SET @WORK_EMAIL = ''
			SET @BRANCH_NAME = ''
			SET @DESIG_NAME = ''
			SET @BODY =''
			SET @TABLEHEAD =''
			SET @TABLEBODY= ''
			SET @SUBJECT= ''
			set @DOB=''
			set @Emp_Image_Name=''
			set @Cmp_Image_Path=''
			set @Cmp_Image_Name=''
		 FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_NAME,@WORK_EMAIL,@BRANCH_NAME,@DESIG_NAME,@DOB,@Emp_Image_Name,@Cmp_Image_Path,@Cmp_Image_Name,@cmp_Name
	   END                    
	CLOSE CUR_EMPLOYEE                    
	DEALLOCATE CUR_EMPLOYEE    
	
	