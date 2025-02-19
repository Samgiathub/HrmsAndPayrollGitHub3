
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_Get_Tax_Declaration]
 @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = '' 

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


    if @Branch_ID = 0  
		 set @Branch_ID = null 
		  
	if @Cat_ID = 0  
		set @Cat_ID = null 
		 
	if @Type_ID = 0  
		set @Type_ID = null 
		 
	if @Dept_ID = 0  
		set @Dept_ID = null  
		
	if @Grd_ID = 0  
		set @Grd_ID = null  
		
	if @Emp_ID = 0  
		set @Emp_ID = null  
    
	 If @Desig_ID = 0  
		set @Desig_ID = null  
    
--Old query comment by hasmukh 23102012    
 --  Select I.IT_name,s.IT_name,S.IT_max_Limit from T0070_IT_Master S Inner join T0040_IT_Deduction I
 --On S.IT_parent_ID =I.IT_Tran_ID where S.Cmp_ID=@Cmp_ID group by I.IT_Name,S.IT_ID ,S.IT_name,S.IT_max_Limit 
 --  order by I.IT_Name  asc

 --New query put by hasmukh 23102012

	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
			Insert Into @Emp_Cons
			
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK)  inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and	I.Increment_effective_Date = Qry.For_Date
							
			Where Cmp_ID = @Cmp_ID 
			--and Isnull(Division_ID,0) = isnull(@Branch_ID ,Isnull(Division_ID,0))
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and Isnull(Cat_ID,0) = isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 						
			
		END			
			
		-- Added By Ali 12012014 -- Start		
			--Declare @DtITHCnt as numeric
			--Set @DtITHCnt = 0			
			--Select @DtITHCnt = COUNT(*) from T0070_IT_MASTER where IT_Is_Header = 1 and Cmp_ID = @Cmp_ID
				
				
			--Declare @DtCnt as numeric
			--Set @DtCnt = 0				
			--Select @DtCnt = COUNT(*) from (
			--	SELECT  ITM.IT_Name,ITD.emp_id,E.Emp_full_name,E.Alpha_Emp_Code,E.Pan_no,ITD.Amount,
			--			ITM.IT_Max_limit,ITM.IT_Alias,ITD.FINANCIAL_YEAR,ITD.For_date,ITM.IT_Def_ID,
			--			ISNULL(IT_Is_Header,0) as IT_Is_Header
			--			,ISNULL(IT_Is_Details,0) as IT_Is_Details
			--			,IT_Level
			--	FROM    T0100_IT_Declaration as ITD 
			--			inner join T0080_emp_master as e on ITD.emp_id  = e.emp_id
			--			inner join T0070_IT_Master as ITM on ITD.IT_ID = ITM.IT_ID
			--			inner join @Emp_Cons as EC on ITD.Emp_Id = EC.Emp_Id					
			--	Where	ITD.Cmp_id = @Cmp_ID 						
			--			and ITD.For_date >= @From_Date 
			--			and ITD.For_date <= @To_Date			
			--	UNION
			--	SELECT  IT_Name,e.Emp_ID ,'' as Emp_full_name,0 as Emp_code,'' as Pan_no,0 as Amount,
			--			IT_Max_limit,IT_Alias,'' as FINANCIAL_YEAR,GETDATE() as For_date,IT_Def_ID,
			--			ISNULL(IT_Is_Header,0) as IT_Is_Header
			--			,ISNULL(IT_Is_Details,0) as IT_Is_Details
			--			,IT_Level
			--	FROM    T0070_IT_Master 
			--			cross join @Emp_Cons e
			--	Where	IT_Is_Header = 1 and Cmp_ID = @Cmp_ID					
			--)as t 
			
			
			--IF @DtCnt = @DtITHCnt
			--	BEGIN
			--			SELECT  ITM.IT_Name,ITD.emp_id,E.Emp_full_name,E.Alpha_Emp_Code,E.Pan_no,ITD.Amount,
			--					ITM.IT_Max_limit,ITM.IT_Alias,ITD.FINANCIAL_YEAR,ITD.For_date,ITM.IT_Def_ID,
			--					ISNULL(IT_Is_Header,0) as IT_Is_Header
			--					,ISNULL(IT_Is_Details,0) as IT_Is_Details
			--					,IT_Level
			--			FROM    T0100_IT_Declaration as ITD 
			--					inner join T0080_emp_master as e on ITD.emp_id  = e.emp_id
			--					inner join T0070_IT_Master as ITM on ITD.IT_ID = ITM.IT_ID
			--					inner join @Emp_Cons as EC on ITD.Emp_Id = EC.Emp_Id					
			--			Where	ITD.Cmp_id = @Cmp_ID 
			--					and ITD.For_date >= @From_Date 
			--					and ITD.For_date <= @To_Date
			--	END
			--ELSE
			--	BEGIN

						-- Added by Hardik 08/06/2020 for Khimji Query of duplicate entries
						DECLARE @FIN_YEAR AS NVARCHAR(20)  		
						SET @FIN_YEAR = CAST(YEAR(@From_Date) AS NVARCHAR) + '-' + CAST(YEAR(@To_Date) AS NVARCHAR)  

						Select * from (
						SELECT  ITM.IT_Name,ITD.emp_id,E.Emp_full_name,E.Alpha_Emp_Code,E.Pan_no,ITD.Amount,
								ITM.IT_Max_limit,ITM.IT_Alias,ITD.FINANCIAL_YEAR,ITD.For_date,ITM.IT_Def_ID,
								ISNULL(IT_Is_Header,0) as IT_Is_Header
								,ISNULL(IT_Is_Details,0) as IT_Is_Details
								,IT_Level
						FROM    T0100_IT_Declaration as ITD WITH (NOLOCK)
								inner join T0080_emp_master as e WITH (NOLOCK) on ITD.emp_id  = e.emp_id
								inner join T0070_IT_Master as ITM WITH (NOLOCK) on ITD.IT_ID = ITM.IT_ID
								inner join @Emp_Cons as EC on ITD.Emp_Id = EC.Emp_Id					
						Where	ITD.Cmp_id = @Cmp_ID 								
								and ITD.For_date >= @From_Date 
								and ITD.For_date <= @To_Date	
								and ITD.Amount > 0 --Ankit After discuss with Hardikbhai	27012016
								and ITD.FINANCIAL_YEAR = @FIN_YEAR
						UNION
						SELECT  IT_Name,e.Emp_ID ,'' as Emp_full_name,'0' as Emp_code,'' as Pan_no,0 as Amount,
								IT_Max_limit,IT_Alias,'' as FINANCIAL_YEAR,GETDATE() as For_date,IT_Def_ID,
								ISNULL(IT_Is_Header,0) as IT_Is_Header
								,ISNULL(IT_Is_Details,0) as IT_Is_Details
								,IT_Level
						FROM    T0070_IT_Master WITH (NOLOCK)
								cross join @Emp_Cons e
						Where	IT_Is_Header = 1 and Cmp_ID = @Cmp_ID					
					)as t 
					Order by t.EMP_ID, t.IT_Level										
				--END
		-- Added By Ali 12012014 -- Start
		
	RETURN
  




