


-- =============================================
-- Author:		<Gadriwala Muslim>
-- ALTER date: <19/01/2015>
-- Description:	<Get Email Address of HR,Account,Manager>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Emp_Details_Ticket]
	@CMP_ID numeric(18,0),
	@EMP_ID numeric(18,0),
	@Ticket_ID numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN		

	DECLARE @Login_Id AS NUMERIC(18,0)
	DECLARE @Branch_id_multi AS VARCHAR(MAX)
	DECLARE @Branch_Name_multi AS NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#Email') IS NOT NULL
		begin
			drop table #Email
		end

	
	SELECT	Emp.Alpha_Emp_Code,Emp.Alpha_Emp_Code +' - '+  Emp.Emp_Full_Name as Emp_Full_Name  ,Qry.Login_ID, Qry.Email_id,Qry.Designation,
			Emp.Emp_Left,Qry.Branch_id_multi, CAST('' AS NVARCHAR(max)) AS Branch_Name_multi 
			,Qry.Emp_ID
	INTO	#Email 
	FROM 
			(
				SELECT	Login_ID,Emp_id,Login_Name,Email_ID_Accou as Email_id,'Account' as Designation,Branch_id_multi
				FROM	T0011_LOGIN  L WITH (NOLOCK) 
				WHERE	Is_Accou = 1 and Emp_ID > 0 and L.Cmp_ID  = @cmp_id
				
				UNION ALL 
				SELECT	Login_ID,Emp_id,Login_Name,Email_ID AS Email_id,'HR' AS Designation ,Branch_id_multi 
				FROM	T0011_LOGIN L WITH (NOLOCK) 
				WHERE	Is_HR = 1 and Emp_ID > 0 and L.Cmp_ID =@cmp_id 
				
				UNION ALL 
				SELECT	Login_ID,Emp_id,Login_Name,Email_ID_HelpDesk AS Email_id,'Travel Help Desk' AS Designation ,Branch_id_multi 
				FROM	T0011_LOGIN L WITH (NOLOCK)
				WHERE	Travel_Help_Desk = 1 and Emp_ID > 0 and L.Cmp_ID =@cmp_id
				
				UNION ALL 
				SELECT	Login_ID,Emp_id,Login_Name,Email_ID_IT AS Email_id,'IT' AS Designation ,Branch_id_multi 
				FROM	T0011_LOGIN L WITH (NOLOCK)  
				WHERE	Is_IT = 1 and Emp_ID > 0 and L.Cmp_ID =@cmp_id 

				UNION ALL 
				SELECT	Login_ID,Emp_id,Login_Name,Email_ID_IT AS Email_id,'Medical Officer' AS Designation ,Branch_id_multi 
				FROM	T0011_LOGIN L WITH (NOLOCK)  
				WHERE	IS_Medical = 1 and Emp_ID > 0 and L.Cmp_ID =@cmp_id 
				
			 ) AS Qry 
	 INNER JOIN T0080_EMP_MASTER emp WITH (NOLOCK) ON emp.Emp_ID = qry.Emp_ID AND Cmp_ID = @cmp_id
	   and emp.Emp_Left <>'Y' --Added by ronakk 14072023
	
	DECLARE CurEmail CURSOR FOR 
	SELECT Login_ID,Branch_id_multi FROM #Email
	OPEN CurEmail
	FETCH NEXT FROM CurEmail INTO @Login_Id,@Branch_id_multi
	WHILE @@FETCH_STATUS = 0
		BEGIN		
			SET @Branch_Name_multi = NULL;
			IF @Branch_id_multi <> '' 
				begin				
					SELECT	@Branch_Name_multi = COALESCE(@Branch_Name_multi + ',','') + ISNULL(Branch_Name,'') 
					FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
							INNER JOIN dbo.Split (@Branch_id_multi,',') ON Data = Branch_ID	
				END
			ELSE
				BEGIN
					SET @Branch_Name_multi = 'All'
				END
			
			UPDATE	#Email 
			SET		Branch_Name_multi = isnull(@Branch_Name_multi ,'')
			WHERE	Login_ID = @Login_id 

			FETCH NEXT FROM CurEmail INTO @Login_Id,@Branch_id_multi
		END
	CLOSE CurEmail	
	DEALLOCATE CurEmail	
		
	DECLARE @DEPTNAME AS VARCHAR(100) = ''
	SELECT @DEPTNAME = TICKET_DEPT_NAME 
	FROM T0040_TICKET_TYPE_MASTER WHERE CMP_ID = @CMP_ID  AND TICKET_DEPT_ID = @TICKET_ID
	ORDER BY TICKET_DEPT_NAME ASC
	
	if ((Select count(1) from #Email where Branch_id_multi in (
		SELECT distinct I.branch_id
		FROM   t0095_increment I 
		INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
		FROM   t0095_increment 
		WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
		GROUP  BY emp_id) Qry 
		ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
		where I.Emp_ID = @Emp_ID) and Designation = @DeptName) > 0)
	BEGIN
	
	select * from (	
		SELECT *,1 as [Default] FROM #Email  where Branch_id_multi in (
		SELECT distinct I.branch_id
		FROM   t0095_increment I 
		INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
		FROM   t0095_increment 
		WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
		GROUP  BY emp_id) Qry 
		ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
		where I.Emp_ID = @Emp_ID) and Designation = @DeptName
		
		--comment start - sandip patel- 28102024
		
		--union  
		--select *,0 as [Default] from #Email where Branch_id_multi not in (
		--SELECT distinct I.branch_id
		--FROM   t0095_increment I 
		--INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
		--FROM   t0095_increment 
		--WHERE  increment_effective_date <= Getdate() AND cmp_id = @Cmp_ID
		--GROUP  BY emp_id) Qry 
		--ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
		--where I.Emp_ID = @Emp_ID)  and Designation = @DeptName

		--comment end - sandip Patel 28102024
		) as s order by [Default] desc
	END
	ELSE
	BEGIN
		
	select * from (	
		SELECT *,1 as [Default] FROM #Email where Branch_id_multi = 0 and Designation = @DeptName
		union 
		select *,0 as [Default] from #Email where Designation = @DeptName and Branch_id_multi <> 0
			) as s order by [Default] desc
	END

	
	   
END


