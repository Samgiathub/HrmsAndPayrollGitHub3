

-- =============================================
-- Author:		<Gadriwala Muslim>
-- ALTER date: <19/01/2015>
-- Description:	<Get Email Address of HR,Account,Manager>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GetEmpEmailTicket]
	@CMP_ID numeric(18,0),
	@Ticket_Id numeric(18,0)
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

	SELECT	Emp.Alpha_Emp_Code,Emp.Emp_Full_Name ,Qry.Login_ID, Qry.Email_id,Qry.Designation,
			Emp.Emp_Left,Qry.Branch_id_multi, CAST('' AS NVARCHAR(max)) AS Branch_Name_multi 
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
			--if @Branch_Name_multi <> ''
			--	begin
			--		set @Branch_Name_multi = substring(@Branch_Name_multi,2,LEN(@Branch_Name_multi))
			--	end
			
			UPDATE	#Email 
			SET		Branch_Name_multi = isnull(@Branch_Name_multi ,'')
			WHERE	Login_ID = @Login_id 
			
			FETCH NEXT FROM CurEmail INTO @Login_Id,@Branch_id_multi
		END
	CLOSE CurEmail	
	DEALLOCATE CurEmail	
			
	
	SELECT TICKET_APP_ID,TICKET_DEPT_NAME,SENDTO,E.Alpha_Emp_Code,Em.Email_id   
	FROM V0090_TICKET_APPLICATION V 
	inner join T0080_EMP_MASTER E on V.Sendto = E.Emp_ID
	Inner join #Email EM on E.Alpha_Emp_Code = EM.Alpha_Emp_Code and V.Ticket_Dept_Name = EM.Designation
	where Ticket_App_ID = @Ticket_Id

END


