






Create VIEW [dbo].[View_Late_Emp_Backupbyronakk_19112022]
AS
SELECT     TOP (100) PERCENT dbo.T0150_EMP_INOUT_RECORD.IO_Tran_Id, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0150_EMP_INOUT_RECORD.For_Date
					--,ISNULL(dbo.T0150_EMP_INOUT_RECORD.In_Time, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time)  as In_Time
					 ,Case when Cast(ISNULL(dbo.T0150_EMP_INOUT_RECORD.In_Time, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time) as Time)  
					 = Cast(Shift_St_Time as Time)
					 then NULL else ISNULL(dbo.T0150_EMP_INOUT_RECORD.In_Time, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time) END	 AS In_Time

					 --,Case when Cast(ISNULL(dbo.T0150_EMP_INOUT_RECORD.Out_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Date_Time) as Time)  
					 --= Cast(Shift_End_Time as Time)
					 --then NULL else ISNULL(dbo.T0150_EMP_INOUT_RECORD.Out_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Date_Time) END AS Out_Time
					 
					 ,dbo.T0150_EMP_INOUT_RECORD.Reason, dbo.T0080_EMP_MASTER.Cmp_ID, I.Branch_ID,I.subBranch_ID,
					  BM.Branch_Name,I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '-' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Varchar(50)) AS Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Alpha_Code, dbo.T0080_EMP_MASTER.Emp_Superior, 
                      ISNULL(dbo.T0150_EMP_INOUT_RECORD.Chk_By_Superior, 0) AS Chk_By_Superior, dbo.T0150_EMP_INOUT_RECORD.Half_Full_day, 
                      dbo.T0150_EMP_INOUT_RECORD.Sup_Comment, dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Name, 
                      ISNULL(dbo.T0150_EMP_INOUT_RECORD.Is_Cancel_Late_In, 0) AS Is_Cancel_Late_In, ISNULL(Qry.Is_Cancel_Early_Out, 0) AS Is_Cancel_Early_Out, 
                      --isnull(Qry1.Out_Time,Qry1.Out_Date_Time) as Out_Time, 
					  --CASE  WHEN CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS DATETIME) > CAST(CONVERT(VARCHAR(16)
					  --,ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120)AS DATETIME) 
					  --Then CAST(CONVERT(VARCHAR(16),QRY2.MAX_IN_TIME,120)as DATETIME) 
					  --Else CAST(CONVERT(VARCHAR(16),ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120) AS DATETIME) End as Out_Time
						CASE  WHEN (CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS TIME) = CAST( Shift_End_Time as time) 
						OR CAST(ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time) AS TIME) = CAST( Shift_End_Time as time)) 
						 Then NULL
						 WHEN CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS DATETIME) > CAST(CONVERT(VARCHAR(16)
						 ,ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120)AS DATETIME) 
						 Then CAST(CONVERT(VARCHAR(16),QRY2.MAX_IN_TIME,120)as DATETIME) 
						 Else CAST(CONVERT(VARCHAR(16),ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120) AS DATETIME) End as Out_Time
					  ,CAST(ERM.Alpha_Emp_Code + '-' + ERM.Emp_Full_Name AS varchar(50)) AS Superior,
                       ERM.Alpha_Emp_Code AS Superior_Code, case when REPLACE(CONVERT(VARCHAR(11),T0150_EMP_INOUT_RECORD.App_Date,103), ' ','/')  = '01/01/1900' then null  else T0150_EMP_INOUT_RECORD.App_Date end as App_Date
                      ,dbo.T0150_EMP_INOUT_RECORD.Other_Reason
                      ,I.Vertical_ID,I.SubVertical_ID --added jimit 29042016
					  ,dbo.T0150_EMP_INOUT_RECORD.In_Time AS Actual_In_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Time AS Actual_Out_Time,s.Shift_End_Time,s.Shift_St_Time
					  --,S.Shift_ID
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK)
		INNER JOIN	dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0150_EMP_INOUT_RECORD.Emp_ID 
		LEFT OUTER JOIN
			(	SELECT  DISTINCT   Is_Cancel_Early_Out, For_Date, Emp_ID
                FROM          dbo.T0150_EMP_INOUT_RECORD AS EIR WITH (NOLOCK)
                WHERE      (Is_Cancel_Early_Out = 1)
             ) AS Qry ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry.Emp_ID 
        LEFT OUTER JOIN
             (	SELECT     For_Date, Emp_ID, MAX(Out_Time) AS Out_Time,Max(Out_Date_Time) as Out_Date_Time
                FROM          dbo.T0150_EMP_INOUT_RECORD AS T0150_EMP_INOUT_RECORD_1 WITH (NOLOCK)
                GROUP BY For_Date, Emp_ID
             ) AS Qry1 ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry1.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry1.Emp_ID 
       LEFT OUTER JOIN
             (	SELECT     For_Date, Emp_ID, MAX(In_Time) AS MAX_IN_TIME
                FROM          dbo.T0150_EMP_INOUT_RECORD AS T0150_EMP_INOUT_RECORD_1 WITH (NOLOCK)
                GROUP BY For_Date, Emp_ID
             ) AS Qry2 ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry2.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry2.Emp_ID 
        INNER JOIN  dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = I.Increment_ID 
        INNER JOIN  dbo.T0040_Reason_Master AS rm WITH (NOLOCK) ON rm.Reason_Name = dbo.T0150_EMP_INOUT_RECORD.Reason and RM.Type = 'R' 
        --LEFT OUTER JOIN  dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 ON T0080_EMP_MASTER.Emp_Superior = T0080_EMP_MASTER_1.Emp_ID
        LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = I.Branch_ID
		LEFT OUTER JOIN T0050_SubBranch SBM WITH (NOLOCK) on SBM.SubBranch_ID = I.SubBranch_ID
       --There is wrong Reporting Manager bind for employee at WCL   changed by jimit 27102017
       Left Join
								(SELECT		Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
								 FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) INNER JOIN
											(SELECT  MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
											 FROM	 T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
											 WHERE	 EFFECT_DATE <= getdate() 
											 GROUP BY EMP_ID)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
								 GROUP BY Q.EMP_ID)MAIN	ON Main.Emp_ID = T0080_EMP_MASTER.Emp_ID LEFT JOIN 
											T0080_EMP_MASTER ERM WITH (NOLOCK) ON MAIN.R_EMP_ID = ERM.EMP_ID AND ERM.EMP_LEFT <> 'Y'		
		Left Join T0040_SHIFT_MASTER s on s.Shift_ID = T0080_EMP_MASTER.Shift_ID
		
WHERE     (dbo.T0150_EMP_INOUT_RECORD.Reason IS NOT NULL) AND (dbo.T0150_EMP_INOUT_RECORD.Reason <> '')
			and (dbo.T0150_EMP_INOUT_RECORD.App_Date is not null or dbo.T0150_EMP_INOUT_RECORD.apr_date is not null) --Added By Jimit 31122018 
ORDER BY dbo.T0080_EMP_MASTER.Emp_code




