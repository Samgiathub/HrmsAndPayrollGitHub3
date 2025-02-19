
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P_Get_Organization_Policy_Doc]
	@Emp_ID		INT
As
	BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		--declare @Emp_ID	INT = 14838
		DECLARE @DEPT_ID INT
		DECLARE @Cmp_ID INT
		
		IF OBJECT_ID(N'tempdb..#TmpDocPolicy') IS NOT NULL
		BEGIN
		DROP TABLE #TmpDocPolicy
		END

		SELECT	TOP 1 @DEPT_ID = Dept_ID, @Cmp_ID = Cmp_ID
		FROM	T0095_INCREMENT	WITH (NOLOCK)
		Where	Emp_ID=@Emp_ID	AND Increment_Effective_Date <= getdate()
		ORDER BY Increment_Effective_Date DESC, Increment_ID DESC
		
		SELECT case when len(Policy_Title) > 30 then left(Policy_Title,30) + '...' else Policy_Title end as Policy_Title,
		P.Policy_Doc_ID,Policy_Upload_Doc,Policy_Tooltip as Policy_Tooltip,Policy_Title  as Policy_Title1 ,Policy_From_Date,p.Emp_ID,
				ISNULL(Dept_Id,0)  as Dept_Id,Policy_To_Date,P.DOC_TYPE,
				(select top 1 'Read'  from T0090_EMP_POLICY_DOC_READ_DETAIL e WITH (NOLOCK)
				 where e.policy_doc_id = p.policy_doc_id and e.emp_id = @Emp_ID 
				 order by read_datetime desc)ReadDocPolicy into #TmpDocPolicy
		FROM	T0040_POLICY_DOC_MASTER P  WITH (NOLOCK)
		WHERE	@Cmp_ID in (SELECT Cast(DATA As INT) FROM dbo.Split(isnull(Cmp_ID_Multi,P.Cmp_ID),'#')) 
				AND Policy_To_Date + 1 >= GETDATE() and Policy_From_Date  <= GETDATE()   
				AND ((@Emp_ID in (select data from dbo.Split(p.emp_id,'#')) or p.Emp_ID like '0')) 
				AND ((@Dept_ID in (select data from dbo.Split(Dept_Id,'#')) or Dept_Id like '0'))
		ORDER BY Policy_From_Date DESC,Policy_Title ASC
		
		select Policy_Title,Policy_Doc_ID,Policy_Upload_Doc,Policy_Tooltip,Policy_Title1,Policy_From_Date,Emp_ID,Dept_Id
		,Policy_To_Date,DOC_TYPE, case when ReadDocPolicy IS NULL THEN 'New' ELSE NULL END as ReadDocPolicy from #TmpDocPolicy

	END
