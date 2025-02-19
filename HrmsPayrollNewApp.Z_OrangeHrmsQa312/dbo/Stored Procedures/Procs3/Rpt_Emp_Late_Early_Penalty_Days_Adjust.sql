

----------------------------------------------------------------------------------------------
--ALTER BY:
--Modified By :
--Description:
--Notes :  Please dont put the Select @Emp_Id like that...
--Late Modified and Review Please Put Comments
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
----------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Rpt_Emp_Late_Early_Penalty_Days_Adjust]    
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   
 ,@Cat_ID  numeric 
 ,@Grd_ID  numeric 
 ,@Type_ID  numeric  
 ,@Dept_ID  numeric  
 ,@Desig_ID  numeric 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(5000) = ''      
 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
	
	declare @sal_st_date	 datetime    
	declare @sal_end_date  datetime     
	declare @outof_days	 numeric           
	declare @increment_id	 numeric    
	declare @is_late_slabwise tinyint
	declare @is_early_slabwise tinyint
	declare @late_dedu_type_inc varchar(10)
	declare @early_dedu_type_inc varchar(10)
	declare @penalty_days_early_late  numeric(18,1) 
	declare @gen_id numeric   


	set @is_late_slabwise  = 0
	set @is_early_slabwise  = 0
	set @late_dedu_type_inc  = 0
	set @early_dedu_type_inc = 0
	set @outof_days = datediff(d,@From_Date,@To_Date) + 1 
	set @gen_id = 0   
	
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
		
	
	 Declare @Emp_Penalty Table      
	 (
		Cmp_id numeric,
		Emp_ID numeric,      
		From_Date  datetime,      
		To_Date  datetime,
		Late_tran_id numeric,
		Leave_Id numeric,
		Leave_Name nvarchar(50),   
		Dedu_type  nvarchar(5),
		Late_days numeric(3,1) ,
		Early_days numeric(3,1) ,
		Penalty_days numeric(3,1),
		leave_balance numeric(18,2),
		total_Penalty numeric(18,2),
		LOP numeric(18,2)
	 )      
	     
	   
	CREATE TABLE #Emp_Cons	-- Ankit 08092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
  
	 --Declare #Emp_Cons Table      
	 --(      
	 --  Emp_ID numeric ,     
	 -- Branch_ID numeric    
	 --)      
	       
	 --if @Constraint <> ''      
	 -- begin      
	 --  Insert Into #Emp_Cons      
	 --  select  cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
	 -- end      
	 --else      
	 -- begin      
	         
	         
	 --  Insert Into #Emp_Cons      
	      
	 --  select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
		-- ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
		-- where Increment_Effective_date <= @To_Date      
		-- and Cmp_ID = @Cmp_ID      
		-- group by emp_ID  ) Qry on      
		-- I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
	 --  Where Cmp_ID = @Cmp_ID       
	 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
	 --  and I.Emp_ID in       
		--( select Emp_Id from      
		--(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
		--where cmp_ID = @Cmp_ID   and        
		--(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
		--or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
		--or Left_date is null and @To_Date >= Join_Date)      
		--or @To_Date >= left_date  and  @From_Date <= left_date )       
	         
	 -- end     

	
	
	insert into @Emp_Penalty (Cmp_id,Emp_ID,Late_tran_id , Late_days,Leave_Id,Leave_Name,Dedu_type,From_Date,To_Date,leave_balance,total_Penalty,LOP)
	select  LA.Cmp_ID,la.Emp_ID,la.Late_Tran_ID ,la.Late_Cal_day, LM.Leave_ID, LM.Leave_Name , la.Approval_Type , @From_Date,@To_Date , isnull(la.Leave_Balance,0) , isnull(la.Total_Penalty_Days,0) , isnull(la.Penalty_days_to_Adjust,0) from T0160_late_Approval LA WITH (NOLOCK)
		INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = la.Leave_ID
		INNER JOIN #Emp_Cons EC on EC.Emp_ID = LA.Emp_ID
	where For_Date >= @From_Date and For_Date <= @To_Date

	
	declare @curDedu_type  nvarchar(5)
	declare @curLate_days numeric(3,1)
	declare @curLate_Tran_ID numeric
	
	set @curDedu_type = ''
	set @curLate_days = 0
	set @curLate_Tran_ID = 0
	
	DECLARE CURH_DAYS CURSOR FOR                  
		select Late_Tran_ID,Dedu_type,late_days from @Emp_Penalty
	OPEN CURH_DAYS                      
	FETCH NEXT FROM CURH_DAYS INTO @curLate_Tran_ID ,@curDedu_type,@curLate_days
	WHILE @@FETCH_STATUS = 0                    
	BEGIN   
		
				--update @Emp_Penalty set LOP = total_Penalty - Late_days where Late_tran_id = @curLate_Tran_ID	
								
				if @curDedu_type = 'L'
					begin
						update @Emp_Penalty set Early_days = 0 , Late_days = @curLate_days  , Penalty_days = 0 where Late_tran_id = @curLate_Tran_ID
					end
				else if @curDedu_type = 'E'
					begin
						update @Emp_Penalty set Early_days = @curLate_days , Late_days = 0 , Penalty_days = 0 where Late_tran_id = @curLate_Tran_ID
					end
				else if @curDedu_type = 'LE'	
					begin
						update @Emp_Penalty set Early_days = 0 , Late_days = 0 , Penalty_days = @curLate_days where Late_tran_id = @curLate_Tran_ID
					end
			
				
				
				FETCH NEXT FROM CURH_DAYS INTO @curLate_Tran_ID ,@curDedu_type,@curLate_days
				
	end                    
	close curH_Days                    
	deallocate curH_Days 
	
	-----commented jimit 28042016-------------------
	--select EP.*,EM.Alpha_Emp_Code ,EM.Emp_Full_Name,CM.Cmp_Name,cm.Cmp_Address,bm.Branch_Name,bm.Branch_Address,bm.Comp_Name,bm.branch_id 
	--from @Emp_Penalty EP 
	--	 inner join T0080_EMP_MASTER EM on EM.Emp_ID =EP.Emp_ID 
	--	 inner join T0010_COMPANY_MASTER CM on cm.Cmp_Id = EP.Cmp_id 
	--	 inner join T0030_BRANCH_MASTER bm on em.branch_id=bm.branch_id		  
	--ORDER BY Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
	--			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
	--			Else Alpha_Emp_Code
	--		 End
	-----------ended-----------------------------------------
		
		
		
		SELECT EP.*,EM.ALPHA_EMP_CODE ,EM.EMP_FULL_NAME,CM.CMP_NAME,CM.CMP_ADDRESS,BM.BRANCH_NAME,BM.BRANCH_ADDRESS,BM.COMP_NAME,BM.BRANCH_ID 
				,GM.GRD_NAME,TM.TYPE_NAME,VS.VERTICAL_NAME,SV.SUBVERTICAL_NAME,DM.DEPT_NAME,DE.DESIG_NAME
		FROM @EMP_PENALTY EP 
		 INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID =EP.EMP_ID 
		 INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = EP.CMP_ID 
		 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EM.BRANCH_ID=BM.BRANCH_ID		
		 Inner JOIN #Emp_Cons EC On Ec.Emp_ID = Em.Emp_ID
		 INNER JOIN T0095_INCREMENT Iq WITH (NOLOCK) On Iq.Increment_ID = Ec.Increment_ID and iq.Emp_ID = Ec.Emp_ID			
		 LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.TYPE_ID = IQ.TYPE_ID
		 LEFT OUTER JOIN T0040_VERTICAL_SEGMENT VS	WITH (NOLOCK) ON VS.VERTICAL_ID = IQ.VERTICAL_ID
		 LEFT OUTER JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON SV.SUBVERTICAL_ID = IQ.SUBVERTICAL_ID
		 LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.GRD_ID = IQ.GRD_ID 
		 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.DEPT_ID = IQ.DEPT_ID
		 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DE WITH (NOLOCK) ON DE.DESIG_ID = IQ.DESIG_ID
					 
	ORDER BY CASE WHEN ISNUMERIC(ALPHA_EMP_CODE) = 1 THEN 
					RIGHT(REPLICATE('0',21) + ALPHA_EMP_CODE, 20)
				ELSE 
					LEFT(ALPHA_EMP_CODE + REPLICATE('',21), 20)				
			 END	

		
		
	RETURN



