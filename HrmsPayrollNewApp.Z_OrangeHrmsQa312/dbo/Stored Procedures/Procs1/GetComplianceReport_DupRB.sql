


--
CREATE PROCEDURE [dbo].[GetComplianceReport_DupRB]
    @Cmp_ID INT,
    @Branch_ID varchar(MAX) = '',
    @Year VArchar(10) = '',
    @Submission_Type INT
	,@submonth INT
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @DynamicSQL NVARCHAR(MAX);
    DECLARE @Columns NVARCHAR(MAX);
	declare @cyear varchar(10) = CAST(CAST(@year as int) + 1 as varchar) 

 --   SELECT @Columns = STRING_AGG(QUOTENAME(Compliance_Name), ', ') 
 --   FROM T0050_COMPLIANCE_MASTER 
 --   WHERE Cmp_ID = @Cmp_ID
 --     AND ((Compliance_Submition_Type = 1)  
 --           OR (Compliance_Submition_Type = 2)  
 --           OR (Compliance_Submition_Type = 3));  


	--SELECT @DynamicSQL = Contr_PersonName from T0035_CONTRACTOR_DETAIL_MASTER WHERE Branch_ID=@Branch_ID 
	--SELECT @Columns AS Compliance_Columns,@DynamicSQL AS Contr_PersonName
   	
--select DATEFROMPARTS(2024, 2, 1)

--select EOMONTH(DATEFROMPARTS(2024, 2, 1));
	
	
	SELECT 
    @Year AS 'CYear',
    CM.Compliance_ID,
    CM.Compliance_Name,
    CM.DUE_DATE,
    Co.Contr_PersonName
		INTO #tmpcmp
		FROM T0050_COMPLIANCE_MASTER CM
		JOIN T0030_BRANCH_MASTER  B

		JOIN T0035_CONTRACTOR_DETAIL_MASTER Co ON Co.Branch_ID = b.Branch_ID
                                     ON B.Branch_ID = Co.Branch_ID 

		WHERE CM.Compliance_Submition_Type = @Submission_Type
		  AND CM.Compliance_View_IN_Dash = 0
		  AND CM.Cmp_ID = @Cmp_ID
		ORDER BY CM.Compliance_Name;
		


		SELECT R.*,tr.*,CONCAT(tr.DUE_DATE,'-',@submonth,'-',CASE WHEN @submonth = 1 THEN   @cyear  ELSE  @Year    END)C_Due_Date
			,CASE 
				WHEN Submission_Date IS NULL
					THEN 'Due'
				WHEN MONTH(Submission_Date) = @submonth AND DAY(Submission_Date) <= tr.[DUE_DATE]  AND R.Year =  @Year  AND Branch_ID LIKE (select data from dbo.Split(@Branch_ID,'#'))
				AND (tr.[DUE_DATE] <= DAY(GETDATE()) OR @submonth <= MONTH(GETDATE()))  THEN 'Compliance' 
				WHEN MONTH(Submission_Date) = @submonth AND DAY(Submission_Date) > tr.[DUE_DATE]  AND R.Year =  @Year  AND Branch_ID LIKE (select data from dbo.Split(@Branch_ID,'#')) THEN 'Non Compliance'
				ELSE 'Due'
				END AS 'status'
		FROM T0050_Repository_Master R
		RIGHT JOIN #tmpcmp tr ON r.Month = DATENAME(MONTH, @submonth)
			AND R.Compliance_ID = tr.Compliance_ID and R.Branch_ID LIKE (select data from dbo.Split(@Branch_ID,'#')) and R.Year = tr.CYear

   

END
