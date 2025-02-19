--Select * from T0080_EMP_MASTER where Alpha_Emp_Code = 'A0003'
-- EXEC SP_Mobile_HRMS_WebService_MyTeam 13961, 119 , 'I'
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_MyTeam]
	@Emp_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Status Varchar(5)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
	If @Status = 'I'
	BEGIN
		Select distinct E.Emp_ID,Q1.Cmp_ID,Alpha_Emp_Code,Emp_Full_Name ,case when Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date) then 1 else 0 END as InOutFlag,Emp_Left
		from T0080_EMP_MASTER E 
		INNER JOIN (
					SELECT Row_ID , Emp_ID ,Cmp_ID , R_Emp_ID , Reporting_Method
						FROM
							(
								SELECT Row_ID , ERD.Emp_ID,Cmp_ID , R_Emp_ID ,Reporting_Method ,  1 AS SortCol
								From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  
									INNER JOIN 
										(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
										 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
										 WHERE Effect_Date <= GETDATE() 
										 GROUP BY EMP_ID
										) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								WHERE ERD.R_Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Reporting_Method = 'Direct'
								--WHERE ERD.R_Emp_ID = @Emp_ID  and Reporting_Method = 'Direct'
								UNION
								SELECT Row_ID , ERD.Emp_ID,Cmp_ID  , R_Emp_ID ,Reporting_Method ,  2 AS SortCol
								From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  
									INNER JOIN 
										(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
										 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
										 WHERE Effect_Date <= GETDATE() 
										 GROUP BY EMP_ID
										) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								--WHERE ERD.Emp_ID = @Emp_ID  and Reporting_Method = 'InDirect'
								WHERE ERD.Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Reporting_Method = 'InDirect'
							)QRY
						--ORDER BY SORTCOL
		) Q1 on E.Emp_ID = q1.Emp_ID
		--Left join T9999_MOBILE_INOUT_DETAIL M on E.Emp_ID=M.Emp_ID
		--Where E.is_for_mobile_Access = 0 and Cast(M.IO_Datetime as date) < CAST(GETDATE() AS Date) 
		Left join T9999_MOBILE_INOUT_DETAIL M on E.Emp_ID=M.Emp_ID and Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date)		
		Where E.is_for_mobile_Access = 0 And IO_Tran_DetailsID is null and Emp_Left = 'N'
	END
	ELSE
	BEGIN
		Select distinct E.Emp_ID,Q1.Cmp_ID,Alpha_Emp_Code,Emp_Full_Name 
		--,case when Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date) then 1 else 0 END as InOutFlag
		,case when Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date) And In_Out_Flag = 'I' then 1 
		when Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date) And In_Out_Flag = 'O' then 2 
			else 0 END as InOutFlag,Emp_Left
			INTO #TmpClockOut
		from T0080_EMP_MASTER E 
		INNER JOIN (
					SELECT Row_ID , Emp_ID ,Cmp_ID , R_Emp_ID , Reporting_Method
						FROM
							(
								SELECT Row_ID , ERD.Emp_ID,Cmp_ID , R_Emp_ID ,Reporting_Method ,  1 AS SortCol
								From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  
									INNER JOIN 
										(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
										 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
										 WHERE Effect_Date <= GETDATE() 
										 GROUP BY EMP_ID
										) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								WHERE ERD.R_Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Reporting_Method = 'Direct'
								--WHERE ERD.R_Emp_ID = @Emp_ID  and Reporting_Method = 'Direct'
								UNION
								SELECT Row_ID , ERD.Emp_ID,Cmp_ID  , R_Emp_ID ,Reporting_Method ,  2 AS SortCol
								From T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  
									INNER JOIN 
										(SELECT MAX(Effect_Date) as Effect_Date, Emp_ID 
										 FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
										 WHERE Effect_Date <= GETDATE() 
										 GROUP BY EMP_ID
										) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date
								--WHERE ERD.Emp_ID = @Emp_ID  and Reporting_Method = 'InDirect'
								WHERE ERD.Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Reporting_Method = 'InDirect'
							)QRY
						--ORDER BY SORTCOL
		) Q1 on E.Emp_ID = q1.Emp_ID
		Left join T9999_MOBILE_INOUT_DETAIL M on E.Emp_ID=M.Emp_ID
		Where E.is_for_mobile_Access = 0 and Cast(M.IO_Datetime as date) = CAST(GETDATE() AS Date)  and Emp_Left = 'N'

		Select Emp_ID,Cmp_ID,Alpha_Emp_Code,Emp_Full_Name,MAX(InOutFlag) as InOutFlag
		from #TmpClockOut 
		Group by Emp_ID,Cmp_ID,	Alpha_Emp_Code,	Emp_Full_Name
		Order by InOutFlag
	END
END
