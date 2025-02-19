

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Common_Request_Detail_Employee]
	 @cmp_id		Varchar(8000)
	,@Request_type	int
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	CREATE TABLE #FinalResult
	(
		Emp_Branch		numeric(18,0)
		,Dept_ID		numeric(18,0)
		,Vertical_ID	numeric(18,0)
		,SubVertical_ID  numeric(18,0)
		,Login_ID		numeric(18,0)
		,Login_Name		varchar(100)
		,emp_name		varchar(100)
		,Cmp_Name	    varchar(100)
		,BranchName		varchar(800)
	)

	DECLARE @sql varchar(max)

    IF @Request_type =0
		BEGIN							 
			set @sql = 'SELECT IE.Branch_ID as Emp_Branch,IE.Dept_ID,IE.Vertical_ID,IE.SubVertical_ID,L.Login_ID,L.Login_Name,(E.Alpha_Emp_Code +''-''+ E.Emp_Full_Name)emp_name,c.Cmp_Name,
						CASE WHEN L.Branch_id_multi is not null THEN
						 (SELECT     bm1.Branch_Name + '', ''
						  FROM       T0030_BRANCH_MASTER BM1 WITH (NOLOCK)
						  WHERE      Branch_ID IN
								   (SELECT     cast(data AS numeric(18, 0))
									 FROM      dbo.Split(isnull(L.Branch_Id_Multi, ''0''), '','')) FOR xml path('''')
									) 
							ELSE ''ALL'' 
						END as Branch
			FROM  T0011_LOGIN L WITH (NOLOCK) inner JOIN
				  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = L.Emp_ID inner JOIN
				   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Vertical_ID,I.SubVertical_ID
							FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
									(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
									 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
											(
													SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
													FROM T0095_INCREMENT WITH (NOLOCK)
													--WHERE cast(CMP_ID as varchar) in (@cmp_id)  
													GROUP BY EMP_ID
											) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
									 --WHERE cast(CMP_ID as varchar) in (@cmp_id) 
									 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
							--WHERE cast(I.CMP_ID as varchar) in (@cmp_id) 
					)IE on ie.Emp_ID = E.Emp_ID inner JOIN
					T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = L.Cmp_ID
			WHERE cast(L.CMP_ID as varchar) in ('+ @cmp_id +') and E.Emp_Left<>''Y'' and  Is_Accou = 1 and L.Is_Default =2
			Order by C.Cmp_Name,E.Emp_ID'
		END
	ELSE IF @Request_type =1
		BEGIN
			set @sql = 'SELECT IE.Branch_ID as Emp_Branch,IE.Dept_ID,IE.Vertical_ID,IE.SubVertical_ID,L.Login_ID,L.Login_Name,(E.Alpha_Emp_Code +''-''+ E.Emp_Full_Name)emp_name,c.Cmp_Name,
						CASE WHEN L.Branch_id_multi is not null THEN
						 (SELECT     bm1.Branch_Name + '', ''
						  FROM       T0030_BRANCH_MASTER BM1 WITH (NOLOCK)
						  WHERE      Branch_ID IN
								   (SELECT     cast(data AS numeric(18, 0))
									 FROM      dbo.Split(isnull(L.Branch_Id_Multi, ''0''), '','')) FOR xml path('''')
									) 
							ELSE ''ALL'' 
						END as Branch
						FROM  T0011_LOGIN L WITH (NOLOCK) inner JOIN
							  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = L.Emp_ID inner JOIN
							   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Vertical_ID,I.SubVertical_ID
										FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
												(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
												 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
														(
																SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																FROM T0095_INCREMENT WITH (NOLOCK)
																--WHERE cast(CMP_ID as varchar) in (@cmp_id)  
																GROUP BY EMP_ID
														) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
												 --WHERE cast(CMP_ID as varchar) in (@cmp_id) 
												 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
										--WHERE cast(I.CMP_ID as varchar) in (@cmp_id) 
								)IE on ie.Emp_ID = E.Emp_ID inner JOIN
								T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = L.Cmp_ID
						WHERE cast(L.CMP_ID as varchar) in ('+ @cmp_id +') and E.Emp_Left<>''Y'' and  IS_HR = 1 and L.Is_Default =2
						Order by C.Cmp_Name,E.Emp_ID'
		END
	ELSE IF @Request_type =2
		BEGIN
			set @sql = 'SELECT IE.Branch_ID as Emp_Branch,IE.Dept_ID,IE.Vertical_ID,IE.SubVertical_ID,L.Login_ID,L.Login_Name,(E.Alpha_Emp_Code +''-''+ E.Emp_Full_Name)emp_name,c.Cmp_Name,
						CASE WHEN L.Branch_id_multi is not null THEN
						 (SELECT     bm1.Branch_Name + '', ''
						  FROM       T0030_BRANCH_MASTER BM1 WITH (NOLOCK)
						  WHERE      Branch_ID IN
								   (SELECT     cast(data AS numeric(18, 0))
									 FROM      dbo.Split(isnull(L.Branch_Id_Multi, ''0''), '','')) FOR xml path('''')
									) 
							ELSE ''ALL'' 
						END as Branch
						FROM  T0011_LOGIN L WITH (NOLOCK) inner JOIN
							  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = L.Emp_ID inner JOIN
							   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Vertical_ID,I.SubVertical_ID
										FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
												(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
												 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
														(
																SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																FROM T0095_INCREMENT WITH (NOLOCK)
																--WHERE cast(CMP_ID as varchar) in (@cmp_id)  
																GROUP BY EMP_ID
														) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
												 --WHERE cast(CMP_ID as varchar) in (@cmp_id) 
												 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
										--WHERE cast(I.CMP_ID as varchar) in (@cmp_id) 
								)IE on ie.Emp_ID = E.Emp_ID inner JOIN
								T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = L.Cmp_ID
						WHERE cast(L.CMP_ID as varchar) in ('+ @cmp_id +') and E.Emp_Left<>''Y'' and  Travel_Help_Desk = 1 and L.Is_Default =2
						Order by C.Cmp_Name,E.Emp_ID'
		END
	ELSE IF @Request_type =3
		BEGIN
			set @sql = 'SELECT IE.Branch_ID as Emp_Branch,IE.Dept_ID,IE.Vertical_ID,IE.SubVertical_ID,L.Login_ID,L.Login_Name,(E.Alpha_Emp_Code +''-''+ E.Emp_Full_Name)emp_name,c.Cmp_Name,
						CASE WHEN L.Branch_id_multi is not null THEN
						 (SELECT     bm1.Branch_Name + '', ''
						  FROM       T0030_BRANCH_MASTER BM1 WITH (NOLOCK)
						  WHERE      Branch_ID IN
								   (SELECT     cast(data AS numeric(18, 0))
									 FROM      dbo.Split(isnull(L.Branch_Id_Multi, ''0''), '','')) FOR xml path('''')
									) 
							ELSE ''ALL'' 
						END as Branch
						FROM  T0011_LOGIN L WITH (NOLOCK) inner JOIN
							  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = L.Emp_ID inner JOIN
							   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Vertical_ID,I.SubVertical_ID
										FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
												(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
												 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
														(
																SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																FROM T0095_INCREMENT WITH (NOLOCK)
																--WHERE cast(CMP_ID as varchar) in (@cmp_id)  
																GROUP BY EMP_ID
														) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
												 --WHERE cast(CMP_ID as varchar) in (@cmp_id) 
												 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
										--WHERE cast(I.CMP_ID as varchar) in (@cmp_id) 
								)IE on ie.Emp_ID = E.Emp_ID inner JOIN
								T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = L.Cmp_ID
						WHERE cast(L.CMP_ID as varchar) in ('+ @cmp_id +') and E.Emp_Left<>''Y'' and  L.IS_IT = 1 and L.Is_Default =2
						Order by C.Cmp_Name,E.Emp_ID'
		END
	ELSE	
		BEGIN
			set @sql = 'SELECT IE.Branch_ID as Emp_Branch,IE.Dept_ID,IE.Vertical_ID,IE.SubVertical_ID,L.Login_ID,L.Login_Name,(E.Alpha_Emp_Code +''-''+ E.Emp_Full_Name)emp_name,c.Cmp_Name,B.Branch_Name
						FROM  T0011_LOGIN L WITH (NOLOCK) inner JOIN
							  T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = L.Emp_ID inner JOIN
							   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID,I.Vertical_ID,I.SubVertical_ID
										FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
												(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
												 FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN
														(
																SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
																FROM T0095_INCREMENT WITH (NOLOCK)
																--WHERE cast(CMP_ID as varchar) in (@cmp_id)  
																GROUP BY EMP_ID
														) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
												 --WHERE cast(CMP_ID as varchar) in (@cmp_id) 
												 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID  AND I.INCREMENT_ID = QRY.INCREMENT_ID
										--WHERE cast(I.CMP_ID as varchar) in (@cmp_id) 
								)IE on ie.Emp_ID = E.Emp_ID inner JOIN
								T0010_COMPANY_MASTER C WITH (NOLOCK) on c.Cmp_Id = L.Cmp_ID left JOIN
								T0030_BRANCH_MASTER B WITH (NOLOCK) On b.Branch_ID = IE.Branch_ID
						WHERE cast(L.CMP_ID as varchar) in ('+ @cmp_id +') and E.Emp_Left<>''Y'' and  isnull(L.IS_IT,0) = 0 and isnull(L.Travel_Help_Desk,0)=0 and isnull(L.Is_HR,0) = 0 and isnull(L.Is_Accou,0)=0 and L.Is_Default =2
						Order by C.Cmp_Name,b.Branch_ID,E.Emp_ID'
		END
	
	--print 	@sql
	INSERT into #FinalResult
	exec(@sql)	
		
	
	SELECT Emp_Branch,Dept_ID,Vertical_ID,SubVertical_ID,Login_ID,Login_Name,emp_name,Cmp_Name,
	case when BranchName LIKE '%,%' then LEFT(BranchName,DATALENGTH(BranchName)-2) else BranchName end as BranchName 
	FROM #FinalResult
	
	DROP TABLE #FinalResult
END

