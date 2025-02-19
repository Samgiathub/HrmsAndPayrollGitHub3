

---------------------------------------------------------
-------Created By Sumit for Allowance Report-----------
---------------------26112014----------------------------
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_AR_APPROVAL_RECORD_GET]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@STATUS	VARCHAR(max)
	,@CONSTRAINT 	VARCHAR(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	
	IF @Status = 'S' or 	@Status =''
		set @Status = null
		

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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
								
		end
		
				
		create table #temp_demo
		(
			Emp_ID numeric(18,0),
			AD_ID  numeric(18,0),
			AD_Mode varchar(255), 
			AD_Percetage numeric(18,2),
			AD_Max_Limt numeric(18,2),
			AD_Amount numeric(18,2),
			Status_1   varchar(255),
			for_date datetime,
			AR_App_ID numeric(18,0)
				
		)



--if @STATUS='0' -------For All----------------
--begin
--declare @AD_one_ID numeric(18,0)
--declare @AR_App_ID numeric(18,0)
--declare @AD_ID numeric(18,0)
--declare @AD_Flag varchar(20)
--declare @ad_one_flag varchar(20)
--declare @emp_one_id numeric(18,0)



--insert into #temp_demo

--select q.Emp_ID,q.AD_ID,q.AD_Mode,q.AD_Percentage,q.E_AD_Max_Limit,q.Total_Amount1 from (
--select row_number() OVER ( PARTITION BY ARE.AD_ID,ARD1.Emp_ID ORDER BY ARD1.Emp_ID DESC )rank,
--E.Emp_ID,ADM.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,ARD1.For_Date,
--ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,
----Type_Name,Dept_Name,Desig_Name,
--ADM.AD_NAME,Cmp_Name,CMP_Address,
----comp_name,branch_name,branch_address,
--ARE.AD_Amount AS Total_Amount1,
--case when ARD1.App_Status=0 then 'Pending' when ARD1.App_Status=1 then 'Approve' when ARD1.App_Status=2 then 'Reject' else 'Not Applied' end as Status_one,
--case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
-- From T0100_AR_ApplicationDetail ARE  inner join 
-- --(select AD_Name from T0050_AD_MASTER AD inner join T0120_GRADEWISE_ALLOWANCE grd on ad.AD_ID=grd.Ad_ID
----) as AD_mstr left join
--					--(select AD_Name from T0050_AD_MASTER AD inner join  )		
--					 T0100_AR_Application ARD1 on ARE.AR_App_ID =ARD1.AR_App_ID left outer join
--					 T0080_EMP_MASTER E on ARD1.emp_ID = E.emp_ID Left Outer Join  	
					 
--					 --T0050_AD_MASTER ADM on ADM.AD_ID=tmp.AD_one_ID left outer join			
--					 --T0050_AD_MASTER ADM on ADM.AD_ID=ARE.AD_ID left outer join
--					 --T0050_AD_MASTER ADM on ADM.CMP_ID=E.Cmp_ID left outer join
--					 --T0120_GRADEWISE_ALLOWANCE GRD on GRD.GRD_ID=E.Grd_id left outer join
--					 T0050_AD_MASTER ADM on ADM.AD_ID=ARE.Ad_ID left outer join
--					 T0080_EMP_MASTER E1 On E1.Emp_ID = ARD1.Emp_ID inner JOIN
--					 @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join
--					 ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I inner join 
--							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
--							where Increment_Effective_date <= @To_Date
--							and Cmp_ID = @Cmp_ID
--							group by emp_ID  ) Qry on
--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
--						on E.Emp_ID = I_Q.Emp_ID  inner join
--							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
--							--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--							--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							
--							--T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id left outer join 
--							--T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  left outer join
--							T0010_Company_Master CM on I_Q.Cmp_ID = CM.Cmp_ID
							 
--				WHERE		E.Cmp_ID = @Cmp_Id				
--				and  ARD1.For_Date >=@From_Date and ARD1.For_Date <=@To_Date
		
--union 
--select row_number() OVER ( PARTITION BY ARE.AD_ID,APR_2.Emp_ID ORDER BY APR_2.Emp_ID DESC )rank,
----select distinct 
--E.Emp_ID,ADM.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,APR_2.For_Date,
--ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,
----Type_Name,Dept_Name,Desig_Name,
--ADM.AD_NAME,Cmp_Name,CMP_Address,
----comp_name,branch_name,branch_address,
--ARE.AD_Amount AS Total_Amount1,
--case when AAR.App_Status=0 then 'Pending' when AAR.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
--case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
-- From T0130_AR_Approval_Detail ARE  inner join
--					T0120_AR_Approval APR_2 on ARE.AR_Apr_ID =APR_2.AR_Apr_ID left outer join
--					T0100_AR_ApplicationDetail ARR on APR_2.Ar_App_ID=ARR.Ar_App_ID left outer join
--					T0100_AR_Application AAR on ARR.AR_App_id =AAR.Ar_App_ID left outer join
--					T0080_EMP_MASTER E on APR_2.emp_ID = E.emp_ID Left Outer Join 
					
--					--T0050_AD_MASTER ADM on ADM.AD_ID=tmp.AD_one_ID left outer join
--					--T0050_AD_MASTER ADM on ADM.AD_ID=ARE.AD_ID left outer join
--					--T0120_GRADEWISE_ALLOWANCE GRD on GRD.GRD_ID=E.Grd_id left outer join
--					T0050_AD_MASTER ADM on ADM.AD_ID=ARE.Ad_ID left outer join
					
--					T0080_EMP_MASTER E1 On E1.Emp_ID = APR_2.Emp_ID inner JOIN
--					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
		
--( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I inner join 
--							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
--							where Increment_Effective_date <= @To_Date
--							and Cmp_ID = @Cmp_ID
--							group by emp_ID  ) Qry on
-- I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
--						on E.Emp_ID = I_Q.Emp_ID  inner join
--							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
--							--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
--							--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
--							--T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id left outer join 
--							--T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  left outer join
--							T0010_Company_Master CM on I_Q.Cmp_ID = CM.Cmp_ID 
--				WHERE		E.Cmp_ID = @Cmp_Id 
-- and  APR_2.For_Date >=@From_Date and APR_2.For_Date <=@To_Date) q  where Rank =1 order BY emp_ID,rank
 
 
 
--   Declare curAR cursor for                      
--		  select distinct AD_ID from VOptionalAllowanceGradewise where cmp_id=@cmp_id and is_optional=1  --and AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail)		  
--		 open curAR  
		                      
--		 fetch next from curAR into @AD_ID
		 
--		 while @@fetch_status = 0                      
--		 begin
--						--print 'AD_ID:'+ @AD_ID;
--						declare Cur_Emp cursor for
--						select Emp_ID from @EMP_CONS 
--							open Cur_Emp;
--							fetch next from Cur_Emp into @emp_one_id
--								while @@FETCH_STATUS=0
--						begin
							
--							SELECT @AD_one_ID = isnull(@AD_ID,0) from VOptionalAllowanceGradewise where cmp_id=@cmp_id and Emp_ID=@emp_one_id and isnull(Is_Optional,0) =1 and @AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail tra inner join T0100_AR_Application tr on tr.AR_App_ID=tra.AR_App_ID where tr.Cmp_ID=@CMP_ID and tr.Emp_ID=@emp_one_id)
							
--							if @AD_one_ID <> 0
--								Begin
								
--								Declare @AD_Mode as varchar(255)
--								Declare @AD_Percentage as numeric(18,2)
--								Declare @AD_Max_Limit numeric(18,2)
--								Declare @AD_Amount numeric(18,2)
								
--								select @AD_Mode=T0120_GRADEWISE_ALLOWANCE.AD_MODE,
--									   @AD_Percentage =	T0120_GRADEWISE_ALLOWANCE.AD_PERCENTAGE,
--									   @AD_Max_Limit =	T0120_GRADEWISE_ALLOWANCE.AD_MAX_LIMIT,
--									   @AD_Amount =	T0120_GRADEWISE_ALLOWANCE.ad_Amount
								
--								 from T0050_AD_MASTER inner join T0120_GRADEWISE_ALLOWANCE
--								  on T0050_AD_MASTER.AD_ID = T0120_GRADEWISE_ALLOWANCE.Ad_ID where T0050_AD_MASTER.AD_ID= @AD_ID and T0050_AD_MASTER.CMP_ID=@cmp_ID
--								  and isnull(Is_Optional,0) =1
								
								
--								INSERT INTO #temp_demo (Emp_ID,AD_ID,AD_Mode,AD_Percetage,AD_Max_Limt,AD_Amount)
--								values(@emp_one_id,@AD_ID,@AD_Mode,@AD_Percentage,@AD_Max_Limit,@AD_Amount)							
--								End
--								fetch next from Cur_Emp into @emp_one_id
--						end ;
--						close Cur_Emp
--						deallocate Cur_Emp	
						
--		--end  		  
		
								  		  
--			--end	  
--		fetch next from curAR into @AD_ID
--		  end
--		close curAR                      
--		deallocate curAR
		
		
   
--   select qry.* from #temp_demo tms
   
   
----   left outer join 
----   (
----   select row_number() OVER (PARTITION BY ARE.AD_ID,ARD1.Emp_ID ORDER BY ARD1.Emp_ID DESC )rank,
----E.Emp_ID,ADM.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,ARD1.For_Date,
----ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,
----Type_Name,Dept_Name,Desig_Name,
----ADM.AD_NAME,
----Cmp_Name,CMP_Address,
----comp_name,branch_name,branch_address,
----ARE.AD_Amount AS Total_Amount1,
----case when ARD1.App_Status=0 then 'Pending' when ARD1.App_Status=1 then 'Approve' when ARD1.App_Status=2 then 'Reject' else 'Not Applied' end as Status_one,
----case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
---- From T0100_AR_ApplicationDetail ARE  inner join 
---- --(select AD_Name from T0050_AD_MASTER AD inner join T0120_GRADEWISE_ALLOWANCE grd on ad.AD_ID=grd.Ad_ID
------) as AD_mstr left join
----					--(select AD_Name from T0050_AD_MASTER AD inner join  )		
----					 T0100_AR_Application ARD1 on ARE.AR_App_ID =ARD1.AR_App_ID left outer join
----					 T0080_EMP_MASTER E on ARD1.emp_ID = E.emp_ID Left Outer Join  	
					 
----					 --T0050_AD_MASTER ADM on ADM.AD_ID=tmp.AD_one_ID left outer join			
----					 --T0050_AD_MASTER ADM on ADM.AD_ID=ARE.AD_ID left outer join
----					 --T0050_AD_MASTER ADM on ADM.CMP_ID=E.Cmp_ID left outer join
----					 --T0120_GRADEWISE_ALLOWANCE GRD on GRD.GRD_ID=E.Grd_id left outer join
					 
----					 T0050_AD_MASTER ADM on ADM.AD_ID=ARE.Ad_ID inner join
----					 --#temp_demo tms on tms.AD_ID=ADM.AD_ID left join
----					 T0080_EMP_MASTER E1 On E1.Emp_ID = ARD1.Emp_ID inner JOIN
----					 @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join
----					 ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I inner join 
----							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
----							where Increment_Effective_date <= @To_Date
----							and Cmp_ID = @Cmp_ID
----							group by emp_ID  ) Qry on
----						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
----						on E.Emp_ID = I_Q.Emp_ID  inner join
----							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
----							T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
----							T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							
----							T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id left outer join 
----							T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  left outer join
----							T0010_Company_Master CM on I_Q.Cmp_ID = CM.Cmp_ID
							 
----				WHERE		E.Cmp_ID = @Cmp_Id				
----				and  ARD1.For_Date >=@From_Date and ARD1.For_Date <=@To_Date
   
----   union
----select row_number() OVER ( PARTITION BY ARE.AD_ID,APR_2.Emp_ID ORDER BY APR_2.Emp_ID DESC )rank,
------select distinct 
----E.Emp_ID,ADM.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,APR_2.For_Date,
----ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,
----Type_Name,Dept_Name,Desig_Name,
----ADM.AD_NAME,Cmp_Name,CMP_Address,
----comp_name,branch_name,branch_address,
----ARE.AD_Amount AS Total_Amount1,
----case when AAR.App_Status=0 then 'Pending' when AAR.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
----case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
---- From T0130_AR_Approval_Detail ARE  inner join
----					T0120_AR_Approval APR_2 on ARE.AR_Apr_ID =APR_2.AR_Apr_ID left outer join
----					T0100_AR_ApplicationDetail ARR on APR_2.Ar_App_ID=ARR.Ar_App_ID left outer join
----					T0100_AR_Application AAR on ARR.AR_App_id =AAR.Ar_App_ID left outer join
----					T0080_EMP_MASTER E on APR_2.emp_ID = E.emp_ID Left Outer Join 
					
----					--T0050_AD_MASTER ADM on ADM.AD_ID=tmp.AD_one_ID left outer join
----					--T0050_AD_MASTER ADM on ADM.AD_ID=ARE.AD_ID left outer join
----					--T0120_GRADEWISE_ALLOWANCE GRD on GRD.GRD_ID=E.Grd_id left outer join
----					T0050_AD_MASTER ADM on ADM.AD_ID=ARE.Ad_ID left outer join
					
----					T0080_EMP_MASTER E1 On E1.Emp_ID = APR_2.Emp_ID inner JOIN
----					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
		
----( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I inner join 
----							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
----							where Increment_Effective_date <= @To_Date
----							and Cmp_ID = @Cmp_ID
----							group by emp_ID  ) Qry on
---- I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
----						on E.Emp_ID = I_Q.Emp_ID  inner join
----							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
----							T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
----							T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
----							T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id left outer join 
----							T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  left outer join
----							T0010_Company_Master CM on I_Q.Cmp_ID = CM.Cmp_ID 
----				WHERE		E.Cmp_ID = @Cmp_Id 
---- and  APR_2.For_Date >=@From_Date and APR_2.For_Date <=@To_Date
   
   
----   ) qry on qry.AD_ID=tms.AD_ID 
----   where Rank =1 order BY qry.emp_ID,rank
  
   
   
		declare @AD_one_ID numeric(18,0)
		declare @AR_App_ID numeric(18,0)
		declare @AD_ID numeric(18,0)
		declare @AD_Flag varchar(20)
		declare @ad_one_flag varchar(20)
		declare @emp_one_id numeric(18,0)
		
		
		Declare @AD_Mode as varchar(255)
		Declare @AD_Percentage as numeric(18,2)
		Declare @AD_Max_Limit numeric(18,2)
		Declare @AD_Amount numeric(18,2)
   
--	end
if @STATUS='0' -------For All----------------
begin
		

				insert into #temp_demo

				select q.Emp_ID,q.AD_ID,q.AD_Mode,q.AD_Percentage,q.E_AD_Max_Limit,q.Total_Amount1,q.Status_one,q.For_Date,q.AR_App_ID from (
				select row_number() OVER ( PARTITION BY ARE.AD_ID,ARD1.Emp_ID ORDER BY ARD1.Emp_ID DESC )rank,
				E.Emp_ID,ARE.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,ARD1.For_Date,
				ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,E.Alpha_Emp_Code as Emp_Code,

				ARE.AD_Amount AS Total_Amount1,
				case when ARD1.App_Status=0 then 'Pending' when ARD1.App_Status=1 then 'Approve' when ARD1.App_Status=2 then 'Reject' else 'Not Applied' end as Status_one,
				case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
				 From T0100_AR_ApplicationDetail ARE WITH (NOLOCK)  inner join 
									 T0100_AR_Application ARD1 WITH (NOLOCK) on ARE.AR_App_ID =ARD1.AR_App_ID left outer join
									 T0080_EMP_MASTER E WITH (NOLOCK) on ARD1.emp_ID = E.emp_ID 						 										
											 
								WHERE		E.Cmp_ID = @Cmp_Id				
								and  ARD1.For_Date >=@From_Date and ARD1.For_Date <=@To_Date 
		
					union 
						select row_number() OVER ( PARTITION BY ARE.AD_ID,APR_2.Emp_ID ORDER BY APR_2.Emp_ID DESC )rank,
						--select distinct 
						E.Emp_ID,ADM.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,APR_2.For_Date,
						ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,E.Alpha_Emp_Code as Emp_Code,
						ARE.AD_Amount AS Total_Amount1,
						--case when AAR.App_Status=0 then 'Pending' when AAR.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
						case when APR_2.Apr_Status=0 then 'Pending' when APR_2.Apr_Status=1 then 'Approve' else 'Reject' end as Status_one,
						case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
						 From T0130_AR_Approval_Detail ARE WITH (NOLOCK) inner join
											T0120_AR_Approval APR_2 WITH (NOLOCK) on ARE.AR_Apr_ID =APR_2.AR_Apr_ID left outer join
											T0100_AR_ApplicationDetail ARR WITH (NOLOCK) on APR_2.Ar_App_ID=ARR.Ar_App_ID left outer join
											T0100_AR_Application AAR WITH (NOLOCK) on ARR.AR_App_id =AAR.Ar_App_ID left outer join
											T0080_EMP_MASTER E WITH (NOLOCK) on APR_2.emp_ID = E.emp_ID Left Outer Join 
															
											T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=ARE.Ad_ID left outer join					
											T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = APR_2.Emp_ID inner JOIN
											@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID 
								

										WHERE		E.Cmp_ID = @Cmp_Id 
						 and  APR_2.For_Date >=@From_Date and APR_2.For_Date <=@To_Date) q where Rank =1 order BY emp_ID,rank
						 
 
 
					  Declare curAR cursor for                      
					  select distinct AD_ID from VOptionalAllowanceGradewise where cmp_id=@cmp_id and is_optional=1  --and AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail)		  
					 open curAR  
					                      
					 fetch next from curAR into @AD_ID
					 
					 while @@fetch_status = 0                      
					 begin
									--print 'AD_ID:'+ @AD_ID;
									declare Cur_Emp cursor for
									select Emp_ID from @Emp_Cons
										open Cur_Emp;
										fetch next from Cur_Emp into @emp_one_id
											while @@FETCH_STATUS=0
									begin
										
										SELECT @AD_one_ID = isnull(@AD_ID,0) from VOptionalAllowanceGradewise where cmp_id=@cmp_id and Emp_ID=@emp_one_id and isnull(Is_Optional,0) =1 --and @AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail tra inner join T0100_AR_Application tr on tr.AR_App_ID=tra.AR_App_ID where tr.Cmp_ID=@CMP_ID and tr.Emp_ID=@emp_one_id)
										if not exists(select AD_ID from T0100_AR_ApplicationDetail tra WITH (NOLOCK)
										inner join T0100_AR_Application tr WITH (NOLOCK) on tr.AR_App_ID=tra.AR_App_ID 
										where tr.Cmp_ID=@cmp_id and tr.Emp_ID=@emp_one_id and ad_ID=@AD_ID)
										begin
										 if not exists(select AD_ID from T0120_AR_Approval tra WITH (NOLOCK) inner join T0130_AR_Approval_Detail tr WITH (NOLOCK)
										 on tr.AR_Apr_ID=tra.AR_Apr_ID
										 where tr.Cmp_ID=@cmp_id and tr.Emp_ID=@emp_one_id and ad_ID=@AD_ID
										 )
										 begin
										if @AD_one_ID <> 0
											Begin
											
											--Declare @AD_Mode as varchar(255)
											--Declare @AD_Percentage as numeric(18,2)
											--Declare @AD_Max_Limit numeric(18,2)
											--Declare @AD_Amount numeric(18,2)
											
											select @AD_Mode=T0120_GRADEWISE_ALLOWANCE.AD_MODE,
												   @AD_Percentage =	T0120_GRADEWISE_ALLOWANCE.AD_PERCENTAGE,
												   @AD_Max_Limit =	T0120_GRADEWISE_ALLOWANCE.AD_MAX_LIMIT,
												   @AD_Amount =	T0120_GRADEWISE_ALLOWANCE.ad_Amount
											
											 from T0050_AD_MASTER WITH (NOLOCK) inner join T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK)
											  on T0050_AD_MASTER.AD_ID = T0120_GRADEWISE_ALLOWANCE.Ad_ID where T0050_AD_MASTER.AD_ID= @AD_one_ID and T0050_AD_MASTER.CMP_ID=@cmp_ID
											  and isnull(Is_Optional,0) =1
											
											
											INSERT INTO #temp_demo (Emp_ID,AD_ID,AD_Mode,AD_Percetage,AD_Max_Limt,AD_Amount)
											values(@emp_one_id,@AD_ID,@AD_Mode,@AD_Percentage,@AD_Max_Limit,@AD_Amount)	
											
											
											
											end						
											End
											end
											fetch next from Cur_Emp into @emp_one_id
									end ;
									close Cur_Emp
									deallocate Cur_Emp	
						
		 
		fetch next from curAR into @AD_ID
		  end
		close curAR                      
		deallocate curAR
		
		
		 
				Update #temp_demo set for_date= 
				 a.for_Date,
				 AR_App_ID=a.ar_app_id
				 from #temp_demo t inner join 
				 (select Emp_ID,MAX(for_Date) as for_Date,max(AR_App_ID)as ar_app_id from #temp_demo 
				 group by Emp_ID
				) a
				 on a.Emp_ID =t.Emp_ID
				 
				 
				 --where a.Emp_ID=@emp_one_id 
											
											   
		 
			select td.*,isnull(td.Status_1,'Not Applied')as Status_one, td.for_date,td.AD_Amount as Total_Amount1,td.AD_Max_Limt as E_AD_Max_Limit,ADM.AD_FLAG, E.Emp_Last_Name,E.Emp_Second_Name,ADM.AD_NAME, E.Street_1,E.City,E.State,E.Emp_Full_Name ,E.Worker_Adult_No,E.Father_Name, E.Alpha_Emp_Code as Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
			--E.Emp_Code,--commented By Mukti 17122015
						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no
						,BM.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
			from #temp_demo td  inner JOIN	dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON td.Emp_ID = E.Emp_ID left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=td.AD_ID left join
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
						@EMP_CONS EC on E.Emp_ID = EC.Emp_ID

			WHERE E.Cmp_ID = @Cmp_Id 			
				Order by  ADM.AD_NAME
				--Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				--When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				--	Else e.Alpha_Emp_Code,ADM.AD_NAME 
		
 

		--end
		drop table #temp_demo
		
		end


	
	if @STATUS='1' ---For Pending-----
	begin
	--Select ALD.*,ARE.*,ARD.AD_Amount as Total_Amount1, E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,Type_Name,Dept_Name,Desig_Name,ADM.AD_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address
	--				,ALD.Total_Amount,@From_Date as From_Date,@To_Date as To_Date,BM.Branch_ID,
	--				case when ARE.App_Status=0 then 'Pending' when ARE.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
	--				case when ARD.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag,
	--				ARD.AD_Mode,ARD.E_AD_Max_Limit
	--				--E.Alpha_Emp_Code As Guarantor_Emp_Code , 
	--				--E1.Emp_Full_Name As Guarantor_Emp_Name
	--			 From T0100_AR_Application ARE inner join 
	--				  --T0100_Loan_Application LA ON MLD.LOAN_APp_ID = LA.LOAN_APp_ID INNER JOIN  -- Commented By rohit for Admin Loan Approval Record not Showing in loan Approval report - on 23072013
	--				  --T0040_LOAN_MASTER LM ON MLD.LOAN_ID = LM.LOAN_ID INNER JOIN 
	--				--T0080_EMP_MASTER E on MLD.emp_ID = E.emp_ID INNER  JOIN 
	--				T0100_AR_ApplicationDetail ARD on ARE.AR_APP_ID= ARD.AR_App_ID left outer join
	--				T0120_AR_Approval ALD on ALD.AR_App_ID=ARE.AR_APP_ID left outer join
	--				T0080_EMP_MASTER E on ARE.emp_ID = E.emp_ID Left Outer Join
					
					
	--				T0050_AD_MASTER ADM on ADM.AD_ID=ARD.AD_ID left outer join
	--				T0080_EMP_MASTER E1 On E1.Emp_ID = ALD.Emp_ID INNER  JOIN --Ankit 02052014
	--				@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
	--				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I inner join 
	--						( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--					on E.Emp_ID = I_Q.Emp_ID  inner join
	--						T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--						T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--						T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--						T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
	--						T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  inner join
	--						T0010_Company_Master CM on I_Q.Cmp_ID = CM.Cmp_ID 
	--			WHERE		E.Cmp_ID = @Cmp_Id 
	--					and ARE.App_Status=0 --isnull(@Status,ALD.Apr_Status) 
	--					and  ARE.For_Date >=@From_Date and ARE.For_Date <=@To_Date
	-----------Above Old commented-----------------------------------------------------
	
	--insert into #temp_demo

	--			select qs.Emp_ID,qs.AD_ID,qs.AD_Mode,qs.AD_Percentage,qs.E_AD_Max_Limit,qs.Total_Amount1,qs.Status_one,qs.For_Date,qs.AR_App_ID
	--			from
	--			(   Select ARE.Emp_ID,ARD.AD_ID,ARD.AD_Mode,ARD.AD_Percentage,ARD.E_AD_Max_Limit,ARD.AD_Amount as Total_Amount1,ARE.App_Status as Status_one,ARE.For_Date,ARE.AR_APP_ID,
	--				 E.Emp_Full_Name,
	--				--Grd_Name,Type_Name,Dept_Name,Desig_Name,ADM.AD_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address,
	--				E.Alpha_Emp_Code as Emp_Code
	--				From T0100_AR_Application ARE  inner join 
	--				T0100_AR_ApplicationDetail ARD on ARE.AR_App_ID=ARD.AR_APP_ID left outer join
	--				--T0080_EMP_MASTER E on ARE.emp_ID = E.emp_ID Left Outer Join
	--				T0120_AR_Approval ALD on ALD.AR_App_ID=ARE.AR_APP_ID left outer join
	--				T0080_EMP_MASTER E on ARE.emp_ID = E.emp_ID 
	--				WHERE		E.Cmp_ID = @Cmp_Id
	--				--T0050_AD_MASTER ADM on ADM.AD_ID=ARD.AD_ID left outer join
	--				--T0080_EMP_MASTER E1 On E1.Emp_ID = ALD.Emp_ID inner JOIN
	--				and ARE.App_Status=0
	--				and  ARE.For_Date >=@From_Date and ARE.For_Date <=@To_Date
					
					
	--			) qs
				
	--			Declare curAR cursor for                      
	--				  select distinct AD_ID from VOptionalAllowanceGradewise where cmp_id=@cmp_id and is_optional=1  --and AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail)		  
	--				 open curAR  
					                      
	--				 fetch next from curAR into @AD_ID
					 
	--				 while @@fetch_status = 0                      
	--				 begin
	--								--print 'AD_ID:'+ @AD_ID;
	--								declare Cur_Emp cursor for
	--								select Emp_ID from @Emp_Cons
	--									open Cur_Emp;
	--									fetch next from Cur_Emp into @emp_one_id
	--										while @@FETCH_STATUS=0
	--								begin
										
	--									SELECT @AD_one_ID = isnull(@AD_ID,0) from VOptionalAllowanceGradewise where cmp_id=@cmp_id and Emp_ID=@emp_one_id and isnull(Is_Optional,0) =1 --and @AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail tra inner join T0100_AR_Application tr on tr.AR_App_ID=tra.AR_App_ID where tr.Cmp_ID=@CMP_ID and tr.Emp_ID=@emp_one_id)
	--									if not exists(select AD_ID from T0100_AR_ApplicationDetail tra 
	--									inner join T0100_AR_Application tr on tr.AR_App_ID=tra.AR_App_ID 
	--									where tr.Cmp_ID=@cmp_id and tr.Emp_ID=@emp_one_id and ad_ID=@AD_ID)
	--									begin
	--									 if not exists(select AD_ID from T0120_AR_Approval tra inner join T0130_AR_Approval_Detail tr 
	--									 on tr.AR_Apr_ID=tra.AR_Apr_ID
	--									 where tr.Cmp_ID=@cmp_id and tr.Emp_ID=@emp_one_id and ad_ID=@AD_ID
	--									 )
	--									 begin
	--									if @AD_one_ID <> 0
	--										Begin
											
											
											
	--										select @AD_Mode=T0120_GRADEWISE_ALLOWANCE.AD_MODE,
	--											   @AD_Percentage =	T0120_GRADEWISE_ALLOWANCE.AD_PERCENTAGE,
	--											   @AD_Max_Limit =	T0120_GRADEWISE_ALLOWANCE.AD_MAX_LIMIT,
	--											   @AD_Amount =	T0120_GRADEWISE_ALLOWANCE.ad_Amount
											
	--										 from T0050_AD_MASTER inner join T0120_GRADEWISE_ALLOWANCE
	--										  on T0050_AD_MASTER.AD_ID = T0120_GRADEWISE_ALLOWANCE.Ad_ID where T0050_AD_MASTER.AD_ID= @AD_one_ID and T0050_AD_MASTER.CMP_ID=@cmp_ID
	--										  and isnull(Is_Optional,0) =1
											
											
	--										INSERT INTO #temp_demo (Emp_ID,AD_ID,AD_Mode,AD_Percetage,AD_Max_Limt,AD_Amount)
	--										values(@emp_one_id,@AD_ID,@AD_Mode,@AD_Percentage,@AD_Max_Limit,@AD_Amount)	
											
											
											
	--										end						
	--										End
	--										end
	--										fetch next from Cur_Emp into @emp_one_id
	--								end ;
	--								close Cur_Emp
	--								deallocate Cur_Emp	
						
		 
	--	fetch next from curAR into @AD_ID
	--	  end
	--	close curAR                      
	--	deallocate curAR
		
		
		 
	--			Update #temp_demo set for_date= 
	--			 a.for_Date,
	--			 AR_App_ID=a.ar_app_id
	--			 from #temp_demo t inner join 
	--			 (select Emp_ID,MAX(for_Date) as for_Date,max(AR_App_ID)as ar_app_id from #temp_demo 
	--			 group by Emp_ID
	--			) a
	--			 on a.Emp_ID =t.Emp_ID
				 
				 
				
	--		select td.*,isnull(td.Status_1,'Not Applied')as Status_one, td.for_date,td.AD_Amount as Total_Amount1,td.AD_Max_Limt as E_AD_Max_Limit,ADM.AD_FLAG, E.Emp_Last_Name,E.Emp_Second_Name,ADM.AD_NAME, E.Street_1,E.City,E.State,E.Emp_Full_Name ,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
	--					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
	--					,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
	--					Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no
						
	--		from #temp_demo td  inner JOIN	dbo.T0080_EMP_MASTER E ON td.Emp_ID = E.Emp_ID left outer join dbo.T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
	--			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I inner join 
	--					( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	-- Ankit 10092014 for Same Date Increment
	--					where Increment_Effective_date <= @To_Date
	--					and Cmp_ID = @Cmp_ID
	--					group by emp_ID  ) Qry on
	--					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--				on E.Emp_ID = I_Q.Emp_ID  inner join
	--					dbo.T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--					dbo.T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--					dbo.T0050_AD_MASTER ADM on ADM.AD_ID=td.AD_ID left join
	--					dbo.T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--					dbo.T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
	--					dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
	--					dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID Inner Join
	--					@EMP_CONS EC on E.Emp_ID = EC.Emp_ID

	--		WHERE E.Cmp_ID = @Cmp_Id 			
	--			Order by  ADM.AD_NAME
			
			
				
	--	drop table #temp_demo
	
	--------------------------------------
	Select ARE.*,ALD.*,ARD.AD_Amount as Total_Amount1, E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,Type_Name,Dept_Name,Desig_Name,ADM.AD_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address
					,ALD.Total_Amount,@From_Date as From_Date,@To_Date as To_Date,BM.Branch_ID,
					case when ARE.App_Status=0 then 'Pending' when ARE.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
					case when ARD.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag,
					ARD.AD_Mode,ARD.E_AD_Max_Limit
					--E.Alpha_Emp_Code As Guarantor_Emp_Code , 
					--E1.Emp_Full_Name As Guarantor_Emp_Name
				 From T0100_AR_Application ARE WITH (NOLOCK) inner join 
					  --T0100_Loan_Application LA ON MLD.LOAN_APp_ID = LA.LOAN_APp_ID INNER JOIN  -- Commented By rohit for Admin Loan Approval Record not Showing in loan Approval report - on 23072013
					  --T0040_LOAN_MASTER LM ON MLD.LOAN_ID = LM.LOAN_ID INNER JOIN 
					--T0080_EMP_MASTER E on MLD.emp_ID = E.emp_ID INNER  JOIN 
					T0100_AR_ApplicationDetail ARD WITH (NOLOCK) on ARE.AR_App_ID=ARD.AR_APP_ID left outer join
					T0120_AR_Approval ALD WITH (NOLOCK) on ALD.AR_App_ID=ARE.AR_APP_ID left outer join
					T0080_EMP_MASTER E WITH (NOLOCK) on ARE.emp_ID = E.emp_ID Left Outer Join
				
					
					T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=ARD.AD_ID left outer join
					T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = ALD.Emp_ID inner JOIN --Ankit 02052014
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id left outer join 
							T0030_Branch_Master BM WITH (NOLOCK)on I_Q.Branch_ID = BM.Branch_ID  left outer join
							T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
				WHERE		E.Cmp_ID = @Cmp_Id 
						and ARE.App_Status=0-- isnull(@Status,ALD.Apr_Status) 
					and  ARE.For_Date >=@From_Date and ARE.For_Date <=@To_Date
					
					Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
				When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
					Else E.Alpha_Emp_Code
					end
					
	
	
	end
	if @STATUS='2' ---For Approve-----
	begin
	Select ALD.*,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,Type_Name,Dept_Name,Desig_Name,ADM.AD_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address
					,ARP.AD_Amount as Total_Amount1,@From_Date as From_Date,@To_Date as To_Date,BM.Branch_ID,
					case when ALD.Apr_Status=0 then 'Pending' when ALD.Apr_Status=1 then 'Approve' else 'Reject' end as Status_one,
					case when ARP.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag,
					ARP.AD_Mode,ARP.E_AD_Max_Limit
					--E.Alpha_Emp_Code As Guarantor_Emp_Code , 
					--E1.Emp_Full_Name As Guarantor_Emp_Name
					From T0120_AR_Approval ALD WITH (NOLOCK) inner join 
					  --T0100_Loan_Application LA ON MLD.LOAN_APp_ID = LA.LOAN_APp_ID INNER JOIN  -- Commented By rohit for Admin Loan Approval Record not Showing in loan Approval report - on 23072013
					  --T0040_LOAN_MASTER LM ON MLD.LOAN_ID = LM.LOAN_ID INNER JOIN 
					--T0080_EMP_MASTER E on MLD.emp_ID = E.emp_ID INNER  JOIN 
					T0130_AR_Approval_Detail ARP WITH (NOLOCK) on ARP.Ar_apr_id=ALD.Ar_Apr_ID left outer join
					T0080_EMP_MASTER E WITH (NOLOCK) on ALD.emp_ID = E.emp_ID Left Outer Join
					T0100_AR_Application ARE WITH (NOLOCK) on ARE.AR_App_ID=ALD.AR_APP_ID left outer join
					--T0100_AR_ApplicationDetail ARD on ARD.AR_App_ID=ALD.AR_APP_ID left outer join
					--T0130_AR_Approval_Detail ARD on ARD.AR_App_ID=ALD.AR_APP_ID left outer join
					
					T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=ARP.AD_ID left outer join
					T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = ALD.Emp_ID INNER  JOIN --Ankit 02052014
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK)  on I_Q.Branch_ID = BM.Branch_ID  inner join
							T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
				WHERE		E.Cmp_ID = @Cmp_Id 
						and ALD.Apr_Status=1 --isnull(@Status,ALD.Apr_Status) 
						and  ALD.For_Date >=@From_Date and ALD.For_Date <=@To_Date
						
						Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
				When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
					Else E.Alpha_Emp_Code
					end
	
	end
	if @STATUS='3' -----For Reject---
	begin
	Select ALD.*,E.Emp_Full_Name,Grd_Name,E.Alpha_Emp_Code as Emp_Code,Type_Name,Dept_Name,Desig_Name,ADM.AD_NAME,Cmp_Name,CMP_Address,comp_name,branch_name,branch_address
					,ARD.AD_Amount as Total_Amount1,@From_Date as From_Date,@To_Date as To_Date,BM.Branch_ID,
					case when ALD.Apr_Status=0 then 'Pending' when ALD.Apr_Status=1 then 'Approve' else 'Reject' end as Status_one,
					case when ARD.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag,
					ARD.AD_Mode,ARD.E_AD_Max_Limit
					--E.Alpha_Emp_Code As Guarantor_Emp_Code , 
					--E1.Emp_Full_Name As Guarantor_Emp_Name
				 From T0120_AR_Approval ALD WITH (NOLOCK) inner join 
					  --T0100_Loan_Application LA ON MLD.LOAN_APp_ID = LA.LOAN_APp_ID INNER JOIN  -- Commented By rohit for Admin Loan Approval Record not Showing in loan Approval report - on 23072013
					  --T0040_LOAN_MASTER LM ON MLD.LOAN_ID = LM.LOAN_ID INNER JOIN 
					--T0080_EMP_MASTER E on MLD.emp_ID = E.emp_ID INNER  JOIN 
					T0130_AR_Approval_Detail ARD WITH (NOLOCK) on ARD.AR_App_ID=ALD.AR_APP_ID left outer join
					T0080_EMP_MASTER E WITH (NOLOCK) on ALD.emp_ID = E.emp_ID Left Outer Join
					T0100_AR_Application ARE WITH (NOLOCK) on ARE.AR_App_ID=ALD.AR_APP_ID left outer join
					--T0100_AR_ApplicationDetail ARD on ARD.AR_App_ID=ALD.AR_APP_ID left outer join
					
					
					T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=ARD.AD_ID left outer join
					T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = ALD.Emp_ID INNER  JOIN --Ankit 02052014
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
							T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID 
				WHERE		E.Cmp_ID = @Cmp_Id 
						and ALD.Apr_Status=2 --isnull(@Status,ALD.Apr_Status) 
						and  ALD.For_Date >=@From_Date and ALD.For_Date <=@To_Date
						
						Order by Case When IsNumeric(E.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + E.Alpha_Emp_Code, 20)
				When IsNumeric(E.Alpha_Emp_Code) = 0 then Left(E.Alpha_Emp_Code + Replicate('',21), 20)
					Else E.Alpha_Emp_Code
					end
	end
	--if @STATUS='4' ----------For Those which are not apply for allowance----------------------
	--	begin
	--		select I_Q.* ,E.Emp_Full_Name , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
	--							,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date
	--							,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
	--				from T0080_EMP_MASTER E left outer join T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID inner join
	--					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I inner join 
	--							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--							where Increment_Effective_date <= @To_Date
	--							and Cmp_ID = @Cmp_ID
	--							group by emp_ID  ) Qry on
	--							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
	--						on E.Emp_ID = I_Q.Emp_ID  inner join
	--							T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
	--							T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
	--							T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
	--							T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
	--							T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
	--							T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID

	--				WHERE E.Cmp_ID = @Cmp_Id	 And E.emp_ID not in 
	--						--(select Emp_ID from T0100_AR_Application TRA inner join T0120_AR_Approval TRP where TRA.For_Date >= @From_Date and TRA.For_Date <= @To_Date And TRA.App_Status=0 and TRP.For_Date>=@From_Date) 
	--						(select Emp_ID from T0100_AR_Application TRA  where TRA.For_Date >= @From_Date and TRA.For_Date <= @To_Date) 
	--						and E.Emp_ID not in
	--						(select Emp_ID from T0120_AR_Approval where for_date >= @From_Date and For_Date <= @To_Date) 
	--						--(select TRA.Emp_ID from T0100_AR_Application TRA inner join T0120_AR_Approval TRP on TRA.Emp_ID=TRP.Emp_ID where TRA.For_Date >= @From_Date and TRA.For_Date <= @To_Date or TRP.For_Date>=@From_Date and TRP.For_Date<=@To_Date) 
	--						And E.Emp_ID in (select Emp_ID From @Emp_Cons)
	--				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
	--		When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
	--			Else e.Alpha_Emp_Code
	--		End			
	--	end	
		
									
	RETURN 




