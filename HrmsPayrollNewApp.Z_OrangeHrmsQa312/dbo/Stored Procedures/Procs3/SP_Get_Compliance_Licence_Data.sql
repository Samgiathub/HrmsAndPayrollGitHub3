
CREATE PROCEDURE [dbo].[SP_Get_Compliance_Licence_Data] 
	@Cmp_ID VARCHAR(2)
	,@Branch_ID VARCHAR(20) = ''
	,@ltype VARCHAR(2)
	,@PrivBranch VARCHAR(200) =  ''
AS
BEGIN
	CREATE TABLE #brachwise_Emp_count
	(Branch_ID int
	,Empcount int
	)

	IF @PrivBranch = '0'
	BEGIN
		INSERT iNTO #brachwise_Emp_count (Branch_ID,Empcount) 
		SELECT EM.Branch_ID
		,COUNT(EM.Emp_ID) Empcount
			FROM T0080_EMP_MASTER EM
			INNER JOIN T0095_INCREMENT INC ON INC.Emp_ID = EM.Emp_ID
			--select INC.Increment_Type,INC.Reason_Name,INC.* from T0095_INCREMENT INC 
			INNER JOIN (
				SELECT MAX(I2.Increment_ID) AS Increment_ID
					,I2.Emp_ID
				FROM T0095_Increment I2
				INNER JOIN T0080_EMP_MASTER E ON I2.Emp_ID = E.Emp_ID
				INNER JOIN (
					SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
						,I3.EMP_ID
					FROM T0095_INCREMENT I3
					INNER JOIN T0080_EMP_MASTER E3 ON I3.Emp_ID = E3.Emp_ID
					WHERE I3.Increment_effective_Date <= GETDATE()
						AND I3.Cmp_ID = @Cmp_ID --and I3.Increment_Type='Transfer'
					GROUP BY I3.EMP_ID
					) I3 ON I2.Increment_Effective_Date = I3.Increment_Effective_Date
					AND I2.EMP_ID = I3.Emp_ID
				GROUP BY I2.Emp_ID
				) I ON INC.Emp_ID = I.Emp_ID
				AND INC.Increment_ID = I.Increment_ID
			WHERE EM.Cmp_ID = @Cmp_ID --and EM.Branch_ID = 31
				AND increment_effective_date <= GETDATE() --order by Increment_Effective_Date desc
			GROUP BY EM.Branch_ID
			
	END
	ELSE
		BEGIN
		INSERT iNTO #brachwise_Emp_count (Branch_ID,Empcount) 
			SELECT EM.Branch_ID
		,COUNT(EM.Emp_ID) Empcount
			FROM T0080_EMP_MASTER EM
			INNER JOIN T0095_INCREMENT INC ON INC.Emp_ID = EM.Emp_ID
			--select INC.Increment_Type,INC.Reason_Name,INC.* from T0095_INCREMENT INC 
			INNER JOIN (
				SELECT MAX(I2.Increment_ID) AS Increment_ID
					,I2.Emp_ID
				FROM T0095_Increment I2
				INNER JOIN T0080_EMP_MASTER E ON I2.Emp_ID = E.Emp_ID
				INNER JOIN (
					SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE
						,I3.EMP_ID
					FROM T0095_INCREMENT I3
					INNER JOIN T0080_EMP_MASTER E3 ON I3.Emp_ID = E3.Emp_ID
					WHERE I3.Increment_effective_Date <= GETDATE()
						AND I3.Cmp_ID = 1 --and I3.Increment_Type='Transfer'
					GROUP BY I3.EMP_ID
					) I3 ON I2.Increment_Effective_Date = I3.Increment_Effective_Date
					AND I2.EMP_ID = I3.Emp_ID
				GROUP BY I2.Emp_ID
				) I ON INC.Emp_ID = I.Emp_ID
				AND INC.Increment_ID = I.Increment_ID
			WHERE EM.Cmp_ID = @Cmp_ID and EM.Branch_ID IN (select data from  dbo.Split(@PrivBranch,','))
				AND increment_effective_date <= GETDATE() --order by Increment_Effective_Date desc
			GROUP BY EM.Branch_ID
		END

		--select * from #brachwise_Emp_count
	IF @ltype = 1
	BEGIN
		SELECT DISTINCT BM.Branch_ID
			,BM.Branch_Name
			,CTD.Nature_Of_Work
			,CTD.Contr_PersonName
			,ctd.Contr_MobileNo
			,ctd.Contr_Email
			,ctd.No_Of_LabourEmployed
			,ISNULL(BMC.Empcount, 0) Emp_Count
			,ctd.Date_Of_Commencement
			,ctd.Date_Of_Termination
			,ctd.LICENCE_DOC
			,DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) Left_Days
			,CASE 
				WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 0 
					THEN 'Expiring Soon'
				ELSE 'Expired'
				END AS 'Status'
		FROM T0030_BRANCH_MASTER BM
		INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CTD ON CTD.Branch_ID = BM.Branch_ID
		INNER JOIN (
			SELECT MAX(Date_Of_Termination) Date_Of_Termination
				,Branch_ID
			FROM T0035_CONTRACTOR_DETAIL_MASTER
			GROUP BY Branch_ID,Nature_Of_Work
			) LCTD ON LCTD.Branch_ID = CTD.Branch_ID
			AND LCTD.Date_Of_Termination = CTD.Date_Of_Termination
		INNER JOIN #brachwise_Emp_count BMC ON BMC.Branch_ID = BM.Branch_ID
		WHERE BM.Cmp_ID = @Cmp_ID
			AND BM.IsActive = 1
			AND BM.Is_Contractor_Branch = 1
			AND (LCTD.Date_Of_Termination BETWEEN GETDATE()
				AND DATEADD(month, 1, GETDATE()) OR LCTD.Date_Of_Termination < GETDATE()) 
		ORDER BY BM.Branch_Name
	END

	IF @ltype = 2
	BEGIN
		--select * from T0080_EMP_MASTER EM where EM.Cmp_ID = 1  and EM.Branch_ID = 69
		--select * from #brachwise_Emp_count
		--return
		SELECT BM.Branch_ID
			,BM.Branch_Name
			,CTD.Nature_Of_Work
			,CTD.Contr_PersonName
			,ctd.Contr_MobileNo
			,ctd.Contr_Email
			,ctd.No_Of_LabourEmployed
			,ISNULL(BMC.Empcount, 0) Emp_Count
			,ctd.Date_Of_Commencement
			,ctd.Date_Of_Termination
			,ctd.LICENCE_DOC
			,DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) Left_Days
			,CASE 
				WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 30
					THEN 'Active'
				WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) <= 30
					AND DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 0 
					THEN 'Expiring Soon'
				ELSE 'Expired'
				END AS 'Status'
		FROM T0030_BRANCH_MASTER BM
		INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CTD ON CTD.Branch_ID = BM.Branch_ID
		INNER JOIN (
			SELECT MAX(Date_Of_Termination) Date_Of_Termination
				,Branch_ID
			FROM T0035_CONTRACTOR_DETAIL_MASTER
			GROUP BY Branch_ID,Nature_Of_Work
			) LCTD ON LCTD.Branch_ID = CTD.Branch_ID
			AND LCTD.Date_Of_Termination = CTD.Date_Of_Termination
		INNER JOIN #brachwise_Emp_count BMC ON BMC.Branch_ID = BM.Branch_ID
		WHERE BM.Cmp_ID = 1
			AND BM.IsActive = 1
			AND BM.Is_Contractor_Branch = 1
		ORDER BY BM.Branch_Name
	END

	IF @ltype = 3
	BEGIN
		SELECT COUNT((
					CASE 
						WHEN T.[Status] = 'Active'
							THEN 1
						END
					)) AS 'Active'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired Soon'
							THEN 1
						END
					)) AS 'Expired Soon'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired'
							THEN 1
						END
					)) AS 'Expired'
			,COUNT(1) AS TotalLicence
		FROM (
			SELECT CASE 
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 30
						THEN 'Active'
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) <= 30
						AND DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 0
						THEN 'Expired Soon'
					ELSE 'Expired'
					END AS 'Status'
			FROM T0030_BRANCH_MASTER BM
			INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CTD ON CTD.Branch_ID = BM.Branch_ID
			INNER JOIN (
				SELECT MAX(Date_Of_Termination) Date_Of_Termination
					,Branch_ID
				FROM T0035_CONTRACTOR_DETAIL_MASTER
				GROUP BY Branch_ID,Nature_Of_Work
				) LCTD ON LCTD.Branch_ID = CTD.Branch_ID
				AND LCTD.Date_Of_Termination = CTD.Date_Of_Termination
			INNER JOIN #brachwise_Emp_count BMC ON BMC.Branch_ID = BM.Branch_ID
			WHERE BM.Cmp_ID = 1
				AND BM.IsActive = 1
				AND BM.Is_Contractor_Branch = 1
			) T

		--////////////////// Geting table data for licence wise ///////////// 

		SELECT T.Nature_Of_Work
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Active'
							THEN 1
						END
					)) AS 'Active'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired Soon'
							THEN 1
						END
					)) AS 'Expired Soon'
			,COUNT((
					CASE 
						WHEN T.[Status] = 'Expired'
							THEN 1
						END
					)) AS 'Expired'
			,COUNT(1) AS TotalLicence
		FROM (
			SELECT CTD.Nature_Of_Work
				,CASE 
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 30
						THEN 'Active'
					WHEN DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) <= 30
						AND DATEDIFF(DAY, GETDATE(), CTD.Date_Of_Termination) > 0
						THEN 'Expired Soon'
					ELSE 'Expired'
					END AS 'Status'
			FROM T0030_BRANCH_MASTER BM
			INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CTD ON CTD.Branch_ID = BM.Branch_ID
			INNER JOIN (
				SELECT MAX(Date_Of_Termination) Date_Of_Termination
					,Nature_Of_Work
					,Branch_ID
				FROM T0035_CONTRACTOR_DETAIL_MASTER
				GROUP BY Nature_Of_Work
					,Branch_ID
				) LCTD ON LCTD.Branch_ID = CTD.Branch_ID
				AND LCTD.Date_Of_Termination = CTD.Date_Of_Termination
			INNER JOIN #brachwise_Emp_count BMC ON BMC.Branch_ID = BM.Branch_ID
			WHERE BM.Cmp_ID = 1
				AND BM.IsActive = 1
				AND BM.Is_Contractor_Branch = 1
			) T
		GROUP BY T.Nature_Of_Work
	END

	IF OBJECT_ID('tempdb..#brachwise_Emp_count') IS NOT NULL
		DROP TABLE #brachwise_Emp_count
			--IF OBJECT_ID('QuarterwiseSale') IS NOT NULL
			--	truncate table QuarterwiseSale
END