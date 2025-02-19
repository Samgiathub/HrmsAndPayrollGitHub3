CREATE VIEW [dbo].[View_BirthdayAlert_08082022]

AS

SELECT 
(SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK) WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1 AND EL.Notification_Flag = 1 ) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id AND EC.Notification_Flag = 1) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment', 
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+ ' ' + ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), Date_Of_Birth,103) AS 'Date' ,
Date_Of_Birth AS 'Date' ,
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Todays Birthday' as 'Groupby',EM.Cmp_ID ,1 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE MONTH(EM.Date_Of_Birth) = MONTH (GETDATE()) AND DAY(EM.Date_Of_Birth) = DAY(GETDATE()) 
AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1 

--GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
--DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--Date_Of_Birth ,EM.Image_Name,EM.Cmp_ID,EM.Gender,EL.Like_Flag

UNION ALL

SELECT 
(SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK)  WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1 AND EL.Notification_Flag = 3 ) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id AND EC.Notification_Flag = 3) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment',  
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+ ' ' + ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), CONVERT(datetime, EM.Emp_Annivarsary_Date,103),103) AS 'Date',
--(CASE WHEN ISNULL(EM.Emp_Annivarsary_Date,'') <> '' THEN CONVERT(varchar(11), CONVERT(datetime, EM.Emp_Annivarsary_Date,103),103) ELSE EM.Emp_Annivarsary_Date END) AS 'Date',
(CASE WHEN ISNULL(EM.Emp_Annivarsary_Date,'') <> '' THEN CONVERT(datetime, EM.Emp_Annivarsary_Date,103) ELSE EM.Emp_Annivarsary_Date END) AS 'Date',
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Todays Marriage Anniversary' as 'Groupby',EM.Cmp_ID ,3 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE MONTH(EM.Emp_Annivarsary_Date) = MONTH (GETDATE()) AND DAY(EM.Emp_Annivarsary_Date) = DAY(GETDATE()) 
AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1

--GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
--DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--Emp_Annivarsary_Date ,EM.Image_Name,EM.Cmp_ID,EM.Gender,EL.Like_Flag

UNION ALL

SELECT (SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK)  WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1 AND EL.Notification_Flag = 2 ) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id AND EC.Notification_Flag = 2) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment',
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+ ' ' + ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), EM.Date_Of_Join,103) AS 'Date',
EM.Date_Of_Join AS 'Date',
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Todays Work Anniversary' as 'Groupby',EM.Cmp_ID ,2 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE MONTH(EM.Date_Of_Join) = MONTH (GETDATE()) AND DAY(EM.Date_Of_Join) = DAY(GETDATE()) 
AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1

--GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
--DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--Date_Of_Join ,EM.Image_Name,EM.Cmp_ID,EM.Gender,EL.Like_Flag

UNION ALL

SELECT (SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK)  WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id ) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment',  
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+ ' ' + ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), Date_Of_Birth,103) AS 'Date',
Date_Of_Birth AS 'Date',
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Upcoming Birthday' as 'Groupby',EM.Cmp_ID ,4 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE (DAY(Date_Of_Birth) > DAY(GETDATE()) AND MONTH(Date_Of_Birth) = MONTH(GETDATE())) 
AND (DAY(Date_Of_Birth) < DAY(GETDATE()+8)  AND MONTH(Date_Of_Birth) = MONTH(GETDATE()))
AND EM.Date_Of_Birth <> '' AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1

--GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
--DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--Date_Of_Birth ,EM.Image_Name,EM.Cmp_ID,EM.Gender,EL.Like_Flag

UNION ALL

SELECT (SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK)  WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id ) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment',  
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+ ' '+ ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), CONVERT(datetime,EM.Emp_Annivarsary_Date,103),103) as 'Date',
--(CASE WHEN ISNULL(EM.Emp_Annivarsary_Date,'') <> '' THEN CONVERT(varchar(11), CONVERT(datetime, EM.Emp_Annivarsary_Date,103),103) ELSE EM.Emp_Annivarsary_Date END) AS 'Date',
(CASE WHEN ISNULL(EM.Emp_Annivarsary_Date,'') <> '' THEN CONVERT(datetime, EM.Emp_Annivarsary_Date,103) ELSE EM.Emp_Annivarsary_Date END) AS 'Date',
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Upcoming Marriage Anniversary' as 'Groupby',EM.Cmp_ID ,6 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE (DAY(Emp_Annivarsary_Date) > DAY(GETDATE()) AND MONTH(Emp_Annivarsary_Date) = MONTH(GETDATE())) 
AND (DAY(Emp_Annivarsary_Date) < DAY(GETDATE()+8)  AND MONTH(Emp_Annivarsary_Date) = MONTH(GETDATE())) -- +8 added by Niraj(08102021)
AND EM.Emp_Annivarsary_Date <> '' AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1

--GROUP BY EM.Emp_ID,EM.Alpha_Emp_Code,EM.Initial,EM.Emp_First_Name,EM.Emp_Second_Name,EM.Emp_Last_Name,
--DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--Emp_Annivarsary_Date ,EM.Image_Name,EM.Cmp_ID,EM.Gender,EL.Like_Flag

UNION ALL

SELECT (SELECT COUNT(*) FROM T0400_Employee_Like EL WITH (NOLOCK)  WHERE EM.Emp_ID = EL.Emp_Id AND EL.Like_Flag = 1) AS 'LikeCount',
(SELECT COUNT(*) FROM T0400_Employee_Comment EC WITH (NOLOCK)  WHERE EM.Emp_ID = EC.Emp_Id ) AS 'CommentCount',
--COUNT(EL.Tran_Id) AS 'Like',COUNT(EC.Comment_Id) AS 'Comment',  
EM.Emp_ID,(EM.Alpha_Emp_Code + ' - ' + EM.Initial + ' '+ ISNULL(EM.Emp_First_Name ,'')+' '+ ISNULL(EM.Emp_Second_Name,'')+  ' '+ISNULL(EM.Emp_Last_Name,'')) AS 'EmpName',
DP.Dept_Name,IC.Desig_Id,DM.Desig_Name,IC.Branch_ID,BM.Branch_Name,BM.Branch_Code,
--CONVERT(varchar(11), EM.Date_Of_Join,103) as 'Date',
EM.Date_Of_Join AS 'Date',
(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = ''  THEN (CASE WHEN EM.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name' , 
'Upcoming Work Anniversary' as 'Groupby',EM.Cmp_ID ,5 AS 'NotificationFlag',ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
FROM T0095_INCREMENT IC WITH (NOLOCK) 
INNER JOIN
(	
	SELECT P.Increment_ID,P.Increment_Effective_Date,P.Emp_ID FROM T0095_INCREMENT P WITH (NOLOCK) 
	INNER JOIN
	(
		SELECT Max(Increment_ID) AS 'Increment_ID',Max(Increment_Effective_Date) as 'Increment_Effective_Date',Emp_ID
		FROM T0095_INCREMENT WITH (NOLOCK) 
		GROUP BY Emp_ID
	)T ON P.Increment_Effective_Date =T.Increment_Effective_Date AND P.Increment_ID = T.Increment_ID AND P.Emp_ID = T.Emp_ID
) AS TIC ON IC.Increment_ID = TIC.Increment_ID
INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  ON IC.Emp_ID = EM.Emp_ID
INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON IC.Branch_ID = BM.Branch_ID
INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  ON IC.Desig_Id = DM.Desig_ID
INNER JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK)  ON IC.Dept_ID = DP.Dept_Id
LEFT JOIN T0400_Employee_Like EL ON EM.Emp_ID = EL.Emp_Like_Id
--LEFT JOIN T0400_Employee_Comment EC ON EM.Emp_ID = EC.Comment_Id

WHERE (DAY(Date_Of_Join) > DAY(GETDATE()) AND MONTH(Date_Of_Join) = MONTH(GETDATE())) 
AND (DAY(Date_Of_Join) < DAY(GETDATE()+8)  AND MONTH(Date_Of_Join) = MONTH(GETDATE())) -- +8 added by Niraj(08102021)
AND EM.Date_Of_Join <> '' AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
--AND EL.Like_Flag = 1

