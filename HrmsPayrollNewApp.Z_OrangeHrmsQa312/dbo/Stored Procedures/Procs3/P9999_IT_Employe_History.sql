


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,28012014>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P9999_IT_Employe_History]
	@Cmp_ID Numeric,
	@Emp_ID Numeric,	
	@Financial_Year Varchar(20),
	@Op tinyint = 0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Op = 0
	BEGIN
		CREATE table #Emp_History 
		(  
			Cmp_Id numeric(18,0),
			Emp_Id numeric(18,0),
			IT_Id numeric(18,0),
			IT_Name varchar(350),
			Financial_Year varchar(50),
			Login_Id numeric(18,0),
			For_Date Datetime,
			Amount numeric(18,2),
			Amount_Ess numeric(18,2),
			Details_1 varchar(Max),
			Details_2 varchar(Max),
			Details_3 varchar(Max),
			Comments varchar(Max),
			Flag numeric(18,0),
			System_date datetime,
			Is_Verified tinyint default 0
		)  
		
		Declare @Flag as numeric
		Set @Flag = 0
		Select @Flag = ISNULL(MAX(Flag),0) from T9999_IT_Employe_History where Cmp_Id = @Cmp_ID and Emp_Id = @Emp_ID and Financial_Year = @Financial_Year
		set @Flag = @Flag + 1 
		
		insert into #Emp_History
		select ITD.CMP_ID,ITD.EMP_ID,ITD.IT_ID,IM.IT_Name,ITD.FINANCIAL_YEAR,
		ITD.LOGIN_ID,ITD.FOR_DATE,ITD.AMOUNT,ITD.AMOUNT_ESS,null,null,null,null,@Flag,GETDATE(),0
		from T0100_IT_DECLARATION ITD WITH (NOLOCK) left outer join
		T0070_IT_MASTER  IM WITH (NOLOCK) ON ITD.IT_ID = IM.IT_ID 
		where ITD.CMP_ID = @Cmp_ID and ITD.EMP_ID = @Emp_ID and ITD.FINANCIAL_YEAR = @Financial_Year
		and IM.IT_Def_ID <> 1
		
		insert into #Emp_History
		select ITD.CMP_ID,ITD.EMP_ID,ITD.IT_ID
		,IM.IT_Name + ' ( '+ convert(varchar(4),ITD.FOR_DATE,100)  + convert(varchar(4),year(ITD.FOR_DATE)) +' ) '
		,ITD.FINANCIAL_YEAR,ITD.LOGIN_ID,ITD.FOR_DATE,ITD.AMOUNT,ITD.AMOUNT_ESS,null,null,null,null,@Flag,GETDATE(),0
		from T0100_IT_DECLARATION ITD WITH (NOLOCK) left outer join
		T0070_IT_MASTER  IM WITH (NOLOCK) ON ITD.IT_ID = IM.IT_ID 
		where ITD.CMP_ID = @Cmp_ID and ITD.EMP_ID = @Emp_ID and ITD.FINANCIAL_YEAR = @Financial_Year
		and IM.IT_Def_ID = 1
		
		
		insert into T9999_IT_Employe_History
		select * from #Emp_History
		
		Drop table #Emp_History
	END
	ELSE
	BEGIN
			Declare @Sys_Date as datetime
			Set @Sys_Date = GETDATE()
						
			DECLARE @Table TABLE( 
				val varchar(50),
				IT_Name varchar(350), 
				Financial_Year varchar(50), 
				Amount numeric(18,2),
				Amount_Ess numeric(18,2)
				--Details_1 varchar(max), 
				--Details_2 varchar(max), 
				--Details_3 varchar(max),
				--Comments varchar(max)
			);

			IF exists (Select Flag from T9999_IT_Employe_History WITH (NOLOCK) where CMP_ID = @Cmp_ID 
			and EMP_ID = @Emp_ID 
			and FINANCIAL_YEAR = @Financial_Year
			group by Flag)
			BEGIN
				
				Set @Sys_Date = (Select top 1 System_date from T9999_IT_Employe_History WITH (NOLOCK) where CMP_ID = @Cmp_ID 
								and EMP_ID = @Emp_ID 
								and FINANCIAL_YEAR = @Financial_Year order by System_date desc)				
				INSERT INTO @Table values('NEW VALUES','Updated on ' + convert(varchar(20),@Sys_Date,103),null,null,null)
				INSERT INTO @Table values(null,null,null,null,null)
			END
			
			Declare @Flagcnt as varchar(500)
			Declare MY_data CURSOR FOR
			Select Flag from T9999_IT_Employe_History WITH (NOLOCK) where CMP_ID = @Cmp_ID 
			and EMP_ID = @Emp_ID 
			and FINANCIAL_YEAR = @Financial_Year 
			group by Flag order by Flag desc
			OPEN MY_data
				FETCH NEXT FROM MY_data INTO @Flagcnt
					WHILE @@FETCH_STATUS = 0
					BEGIN
			 
						INSERT INTO @Table
						Select null,IT_Name,Financial_Year,Amount,Amount_Ess
						from T9999_IT_Employe_History WITH (NOLOCK) where Cmp_Id = @Cmp_ID 
						and Emp_Id = @Emp_ID
						and Financial_Year = @Financial_Year
						and Flag = @Flagcnt
						order by Flag desc 			
						
						if @Flagcnt <> 1
						BEGIN									
							Set @Sys_Date =(Select top 1 System_date from T9999_IT_Employe_History WITH (NOLOCK)
							where Cmp_Id = @Cmp_ID 
							and Emp_Id = @Emp_ID
							and Financial_Year = @Financial_Year
							and Flag = @Flagcnt - 1)
							print convert(varchar(20),@Sys_Date,103)
							INSERT INTO @Table values(null,null,null,null,null)
							INSERT INTO @Table values('OLD VALUES','Updated on ' + convert(varchar(20),@Sys_Date,103),null,null,null)
							INSERT INTO @Table values(null,null,null,null,null)
						END
					FETCH NEXT FROM MY_data INTO @Flagcnt
					END
				CLOSE MY_data
			DEALLOCATE MY_data
			
			Select * from @Table
  	END
END


