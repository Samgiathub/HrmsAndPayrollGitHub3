


---------------------------------------------------------
-------Created By Sumit for Allowance Report-----------
---------------------26112014----------------------------
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_AR_APPROVAL_RECORD_GET_TEST]
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
		

	CREATE table #Emp_cons
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into #Emp_cons

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
			Status_1   varchar(255)
				
		)
		
		
if @STATUS='0' -------For All----------------
begin
		declare @AD_one_ID numeric(18,0)
		declare @AR_App_ID numeric(18,0)
		declare @AD_ID numeric(18,0)
		declare @AD_Flag varchar(20)
		declare @ad_one_flag varchar(20)
		declare @emp_one_id numeric(18,0)



				insert into #temp_demo

				select q.Emp_ID,q.AD_ID,q.AD_Mode,q.AD_Percentage,q.E_AD_Max_Limit,q.Total_Amount1,q.Status_one from (
				select row_number() OVER ( PARTITION BY ARE.AD_ID,ARD1.Emp_ID ORDER BY ARD1.Emp_ID DESC )rank,
				E.Emp_ID,ARE.AD_ID, ARE.AR_App_ID,ARE.Cmp_ID,ARD1.For_Date,
				ARE.AD_Percentage,ARE.E_AD_Max_Limit,ARE.AD_Mode,E.Emp_Full_Name,E.Alpha_Emp_Code as Emp_Code,

				ARE.AD_Amount AS Total_Amount1,
				case when ARD1.App_Status=0 then 'Pending' when ARD1.App_Status=1 then 'Approve' when ARD1.App_Status=2 then 'Reject' else 'Not Applied' end as Status_one,
				case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
				 From T0100_AR_ApplicationDetail ARE  WITH (NOLOCK) inner join 
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
						case when AAR.App_Status=0 then 'Pending' when AAR.App_Status=1 then 'Approve' else 'Reject' end as Status_one,
						case when ARE.AD_Flag='I' then 'Earning' else 'Deduction' end as AD_Flag
						 From T0130_AR_Approval_Detail ARE WITH (NOLOCK) inner join
											T0120_AR_Approval APR_2 WITH (NOLOCK) on ARE.AR_Apr_ID =APR_2.AR_Apr_ID left outer join
											T0100_AR_ApplicationDetail ARR WITH (NOLOCK) on APR_2.Ar_App_ID=ARR.Ar_App_ID left outer join
											T0100_AR_Application AAR WITH (NOLOCK) on ARR.AR_App_id =AAR.Ar_App_ID left outer join
											T0080_EMP_MASTER E WITH (NOLOCK) on APR_2.emp_ID = E.emp_ID Left Outer Join 
															
											T0050_AD_MASTER ADM WITH (NOLOCK) on ADM.AD_ID=ARE.Ad_ID left outer join					
											T0080_EMP_MASTER E1 WITH (NOLOCK) On E1.Emp_ID = APR_2.Emp_ID inner JOIN
											#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID 
								

										WHERE		E.Cmp_ID = @Cmp_Id 
						 and  APR_2.For_Date >=@From_Date and APR_2.For_Date <=@To_Date) q  where Rank =1 order BY emp_ID,rank
						 
 
 
					  Declare curAR cursor for                      
					  select distinct AD_ID from VOptionalAllowanceGradewise where cmp_id=@cmp_id and is_optional=1  --and AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail)		  
					 open curAR  
					                      
					 fetch next from curAR into @AD_ID
					 
					 while @@fetch_status = 0                      
					 begin
									--print 'AD_ID:'+ @AD_ID;
									declare Cur_Emp cursor for
									select Emp_ID from #Emp_Cons 
										open Cur_Emp;
										fetch next from Cur_Emp into @emp_one_id
											while @@FETCH_STATUS=0
									begin
										
										SELECT @AD_one_ID = isnull(@AD_ID,0) from VOptionalAllowanceGradewise where cmp_id=@cmp_id and Emp_ID=@emp_one_id and isnull(Is_Optional,0) =1 and @AD_ID not in (select AD_ID from T0100_AR_ApplicationDetail tra WITH (NOLOCK) inner join T0100_AR_Application tr WITH (NOLOCK) on tr.AR_App_ID=tra.AR_App_ID where tr.Cmp_ID=@CMP_ID and tr.Emp_ID=@emp_one_id)
										
										if @AD_one_ID <> 0
											Begin
											
											Declare @AD_Mode as varchar(255)
											Declare @AD_Percentage as numeric(18,2)
											Declare @AD_Max_Limit numeric(18,2)
											Declare @AD_Amount numeric(18,2)
											
											select @AD_Mode=T0120_GRADEWISE_ALLOWANCE.AD_MODE,
												   @AD_Percentage =	T0120_GRADEWISE_ALLOWANCE.AD_PERCENTAGE,
												   @AD_Max_Limit =	T0120_GRADEWISE_ALLOWANCE.AD_MAX_LIMIT,
												   @AD_Amount =	T0120_GRADEWISE_ALLOWANCE.ad_Amount
											
											 from T0050_AD_MASTER WITH (NOLOCK) inner join T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK)
											  on T0050_AD_MASTER.AD_ID = T0120_GRADEWISE_ALLOWANCE.Ad_ID where T0050_AD_MASTER.AD_ID= @AD_ID and T0050_AD_MASTER.CMP_ID=@cmp_ID
											  and isnull(Is_Optional,0) =1
											
											
											INSERT INTO #temp_demo (Emp_ID,AD_ID,AD_Mode,AD_Percetage,AD_Max_Limt,AD_Amount)
											values(@emp_one_id,@AD_ID,@AD_Mode,@AD_Percentage,@AD_Max_Limit,@AD_Amount)							
											End
											fetch next from Cur_Emp into @emp_one_id
									end ;
									close Cur_Emp
									deallocate Cur_Emp	
						
		 
		fetch next from curAR into @AD_ID
		  end
		close curAR                      
		deallocate curAR
		
   
			select td.*,E.Emp_Last_Name,E.Emp_Second_Name, E.Street_1,E.City,E.State,E.Emp_Full_Name ,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no
						
			from #temp_demo td  inner JOIN	dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON td.Emp_ID = E.Emp_ID left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment	WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

			WHERE E.Cmp_ID = @Cmp_Id	
			
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
		
 

		end
		
		end
	
	
									
	RETURN 




