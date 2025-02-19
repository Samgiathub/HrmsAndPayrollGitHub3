
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GoalInitiate_Schedule_Reminder_Rater] AS BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @emp_id int ,@KPA_InitiateId nvarchar(20),@Emp_Full_Name nvarchar(MAX),@Manager_Name nvarchar(MAX),
@Manager_Email nvarchar(MAX),@Submited_date nvarchar(MAX),@Initiate_Status int,@Dept_Name nvarchar(MAX),
@Cmp_Id AS numeric,
@profile AS varchar(50);
SET @profile = '' DECLARE emp_cursor
CURSOR
FOR
SELECT KS.Emp_Id,
       KS.KPA_InitiateId,
       E.Emp_Full_Name AS Emp_Full_Name,
       CASE
           WHEN KS.RM_Required = 1 THEN ERE.Emp_Full_Name
           ELSE ''
       END AS Manager_Name,
       CASE
           WHEN KS.RM_Required = 1 THEN ERE.Work_Email
           ELSE ''
       END AS Manager_Email,
       Emp_ApprovedDate AS Submited_date,
       KS.Initiate_Status,
       D.Dept_Name,
       KS.Cmp_Id
FROM dbo.T0055_Hrms_Initiate_KPASetting AS KS WITH (NOLOCK)
LEFT OUTER JOIN
  (SELECT R.Emp_ID,R.R_Emp_ID FROM dbo.T0090_EMP_REPORTING_DETAIL AS R WITH (NOLOCK)
  INNER JOIN
       (SELECT MAX(R1.Row_ID) AS ROW_ID,
             R1.Emp_ID
      FROM dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
      INNER JOIN
        (SELECT MAX(R2.Effect_Date) AS EFFECT_DATE,
                R2.Emp_ID
         FROM dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
         INNER JOIN dbo.T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) ON R2.Emp_ID = dbo.T0055_Hrms_Initiate_KPASetting.Emp_Id
         AND R2.Effect_Date <= dbo.T0055_Hrms_Initiate_KPASetting.KPA_StartDate
         GROUP BY R2.Emp_ID) AS R2 ON R1.Emp_ID = R2.Emp_ID
      AND R1.Effect_Date = R2.EFFECT_DATE
      GROUP BY R1.Emp_ID) AS R1 ON R.Emp_ID = R1.Emp_ID
   AND R.Row_ID = R1.ROW_ID) AS RE ON KS.Emp_Id = RE.Emp_ID
LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS E WITH (NOLOCK) ON E.Emp_ID = KS.Emp_Id
LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS ERE WITH (NOLOCK) ON ERE.Emp_ID = RE.R_Emp_ID
LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS EHO WITH (NOLOCK) ON EHO.Emp_ID = KS.Hod_Id
LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS EGH WITH (NOLOCK) ON EGH.Emp_ID = KS.GH_Id
INNER JOIN dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON I.Emp_ID = KS.Emp_Id
INNER JOIN
  (SELECT MAX(dbo.T0095_INCREMENT.Increment_ID) AS Increment_ID,
          dbo.T0095_INCREMENT.Emp_ID
   FROM dbo.T0095_INCREMENT WITH (NOLOCK)
   INNER JOIN
     (SELECT MAX(T0095_INCREMENT_1.Increment_Effective_Date) AS Increment_Effective_Date,
             T0095_INCREMENT_1.Emp_ID
      FROM dbo.T0095_INCREMENT AS T0095_INCREMENT_1 WITH (NOLOCK)
      INNER JOIN dbo.T0055_Hrms_Initiate_KPASetting AS T0055_Hrms_Initiate_KPASetting_1 WITH (NOLOCK) ON T0095_INCREMENT_1.Emp_ID = T0055_Hrms_Initiate_KPASetting_1.Emp_Id
      AND T0095_INCREMENT_1.Increment_Effective_Date <= T0055_Hrms_Initiate_KPASetting_1.KPA_StartDate
      GROUP BY T0095_INCREMENT_1.Emp_ID) AS I2 ON I2.Emp_ID = dbo.T0095_INCREMENT.Emp_ID
   GROUP BY dbo.T0095_INCREMENT.Emp_ID) AS I1 ON I1.Emp_ID = I.Emp_ID
AND I1.Increment_ID = I.Increment_ID
LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID
LEFT OUTER JOIN dbo.T0040_GRADE_MASTER AS G WITH (NOLOCK) ON G.Grd_ID = I.Grd_ID
LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id
WHERE ks.Initiate_Status = 2 AND DATEDIFF(DAY, Emp_ApprovedDate, getdate()) % 7 = 0 
  
  OPEN emp_cursor FETCH NEXT
  FROM emp_cursor INTO @emp_id,
                       @KPA_InitiateId,
                       @Emp_Full_Name,
                       @Manager_Name,
                       @Manager_Email,
                       @Submited_date,
                       @Initiate_Status,
                       @Dept_Name,
                       @Cmp_Id WHILE @@FETCH_STATUS = 0 BEGIN
SELECT @profile = isnull(DB_Mail_Profile_Name, '')
FROM t9999_Reminder_Mail_Profile
WHERE cmp_id = @Cmp_Id
DECLARE @Body AS VARCHAR(MAX)
  SET @Body = '<html>
   <head>
   </head>
   <body>
      <table border="0" cellpadding="2" cellspacing="0" width="100%">
         <tbody>
            <tr bgcolor="#FFFFFF">
               <td class="awards">
                  <div align="justify">
                     <p>
                        <font face="Verdana" size="2">Dear <strong>'+@Manager_Name+'</strong></font>
                     </p>
                  </div>
               </td>
            </tr>
            <tr bgcolor="#FFFFFF">
               <td>
                  <font face="Verdana" size="2">&nbsp;</font>
               </td>
            </tr>
            <tr bgcolor="#FFFFFF">
               <td style="height: 162px">
                  <table bgcolor="#999999" border="0" cellpadding="3" cellspacing="1" width="100%">
                     <tbody>
                        <tr>
                           <td bgcolor="#f2f2f2" class="awards" colspan="2" height="20">
                              <strong><font color="#D9AD00" face="Tahoma, Verdana" size="2">Interview Details</font></strong>
                           </td>
                        </tr>
                        <tr>
                           <td bgcolor="#f2f2f2" class="awards">
                              <font face="Verdana" size="2"><strong>Employee Name</strong></font>
                           </td>
                           <td bgcolor="#FFFFFF" class="awards_black">
                              <font face="Verdana" size="2">'+ @Emp_Full_Name+'</font>
                           </td>
                        </tr>                       
                        <tr>
                           <td bgcolor="#f2f2f2" class="awards">
                              <font face="Verdana" size="2"><strong>Submited Date</strong></font>
                           </td>
                           <td bgcolor="#FFFFFF" class="awards_black">
                              <font face="Verdana" size="2">'+@Submited_date+'</font>
                           </td>
                        </tr>
                        <tr>
                           <td bgcolor="#f2f2f2" class="awards">
                              <font face="Verdana" size="2"><strong>Department</strong></font>
                           </td>
                           <td bgcolor="#FFFFFF" class="awards_black">
                              <font face="Verdana" size="2">'+isnull(@Dept_Name, '')+'</font>
                           </td>
                        </tr>                        
                     </tbody>
                  </table>
               </td>
            </tr>
         </tbody>
      </table>'
      	SELECT @Body
 --EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile,
 --                             @recipients = @Manager_Email,
 --                             @subject = 'Review Employee Goal',
 --                             @body = @Body,
 --                             @body_format = 'HTML'
                              --@copy_recipients = @memberemails 
                              FETCH NEXT
  FROM emp_cursor INTO @emp_id,
                       @KPA_InitiateId,
                       @Emp_Full_Name,
                       @Manager_Name,
                       @Manager_Email,
                       @Submited_date,
                       @Initiate_Status,
                       @Dept_Name,
                       @Cmp_Id END CLOSE emp_cursor;

DEALLOCATE emp_cursor;

END