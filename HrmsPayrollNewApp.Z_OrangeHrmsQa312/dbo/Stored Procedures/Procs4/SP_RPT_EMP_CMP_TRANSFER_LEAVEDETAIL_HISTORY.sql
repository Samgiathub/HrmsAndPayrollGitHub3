

-- =============================================
-- Author:		<JIMTT>
-- Create date: <23112015>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER_LEAVEDETAIL_HISTORY]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric  = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric  = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric  = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @Branch_ID = 0
		Set @Branch_ID = null
	If @Cat_ID = 0
		Set @Cat_ID = null
	If @Type_ID = 0
		Set @Type_ID = null
	If @Dept_ID = 0
		Set @Dept_ID = null
	If @Grd_ID = 0
		Set @Grd_ID = null
	If @Emp_ID = 0
		Set @Emp_ID = null
	If @Desig_ID = 0
		Set @Desig_ID = null
		
	
	Create Table #Emp_Cons 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )      
		 
	 Create Table #Emp_Cons_temp
	 (      
	   Old_Cmp_Id  NUMERIC,
	   New_Cmp_Id NUMERIC,
	   Old_Emp_Id NUMERIC,
	   New_Emp_Id NUMERIC	   
	 ) 
 

	
	If @Constraint <> ''
		Begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		End
					
	declare @New_Emp_Id numeric
	declare @Old_Emp_Id numeric
	declare @New_cmp_Id numeric
	declare @old_cmp_Id numeric
	DECLARE @row_Id numeric --= 1 
	
	SET @row_Id = 1  --changed jimit 20042016
	--Declare Cursor_EmpTransfer cursor for	                 
	--					select Emp_ID From #Emp_Cons 
						
	--					Open Cursor_EmpTransfer
	--						Fetch next from Cursor_EmpTransfer into @CurTeam_Emp_Id
	--						While @@fetch_status = 0                    
	--							Begin 						
									--INSERT into #Emp_Cons_temp	VALUES(@Row_Id,@CurTeam_Emp_Id,@cmP_id)
									
									--	select @New_Emp_Id = ISNULL(New_Emp_Id,0),@Old_Emp_Id=ISNULL(Old_Emp_Id,0),@New_cmp_Id=ISNULL(New_Cmp_Id,0),@old_cmp_Id=ISNULL(Old_Cmp_Id ,0)
									--	from T0095_EMP_COMPANY_TRANSFER where Old_Cmp_Id = @CmP_id and Old_Emp_Id = @CurTeam_Emp_Id
																						
									--while @New_Emp_Id <> 0
									--		Begin													
									--			select @New_Emp_Id = New_Emp_Id,@Old_Emp_Id=Old_Emp_Id,@New_cmp_Id=New_Cmp_Id,@old_cmp_Id=Old_Cmp_Id 
									--			from T0095_EMP_COMPANY_TRANSFER where Old_Cmp_Id = @old_cmp_Id and Old_Emp_Id = @Old_Emp_Id												
									--				if @New_Emp_Id <> 0
									--				BEGIN																
									--						if EXISTS(select  New_Emp_Id,Old_Emp_Id,New_Cmp_Id,Old_Cmp_Id 
									--						from T0095_EMP_COMPANY_TRANSFER where Old_Cmp_Id = @old_cmp_Id and Old_Emp_Id = @Old_Emp_Id)
									--								BEGIN
									--									Set @old_cmp_Id = @New_cmp_Id
									--									Set @old_emp_Id = @New_Emp_Id
																		
									--									select @row_Id =  Isnull(max(Row_ID),0) + 1 from #Emp_Cons_temp
																		
									--									INSERT into #Emp_Cons_temp
									--									VALUES(@Row_Id,@New_Emp_Id,@New_cmp_Id)													
									--										--print @row_Id
									--										--print @New_Emp_Id
									--										------print @Old_Emp_Id
									--										--print @New_cmp_Id
									--										--print @old_cmp_Id	
									--									Set @row_Id = @row_Id + 1
									--								end
									--						else
									--						 begin 
															
									--							set @New_Emp_Id = 0
									--						 END
									--				END
									--				ELSE
									--					BEGIN
									--						set @New_Emp_Id = 0
																
									--					end	
									--			--set @Cnt = @Cnt + 1												
									--		end
									
												
													
													--insert into #Emp_Cons_temp
													--VALUES(select * from cte)
									
		--				fetch next from Cursor_EmpTransfer into @CurTeam_Emp_Id	
		--			End
		--	Close Cursor_EmpTransfer                    
		--Deallocate Cursor_EmpTransfer	
	 	
	 			
	 			;with cte as
						(  
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner JOIN
						  #Emp_Cons EC On Ec.Emp_ID = T.Old_Emp_Id
						  where T.Old_Emp_Id = Ec.Emp_ID
						  union all
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK)
							inner join cte as C
							  on T.Old_Emp_Id = C.New_Emp_Id
						)
						select * 
						into #Temp
						from cte
						
	 			;with cte as
						(  
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK) inner JOIN
						  #Emp_Cons EC On Ec.Emp_ID = T.Old_Emp_Id
						  where T.New_Emp_Id = Ec.Emp_ID
						  union all
						  select T.Old_Cmp_Id,T.New_Cmp_Id,T.Old_Emp_Id,T.New_Emp_Id
						  from T0095_EMP_COMPANY_TRANSFER as T WITH (NOLOCK)
							inner join cte as C
							  on T.New_Emp_Id = C.Old_Emp_Id
						)
						select * 
						into #Temp1
						from cte
	 					
	 						
	 			insert into #Emp_Cons_temp
	 			SELECT * from #temp
	 			union ALL 
	 			select * from #temp1
	 			order By Old_emp_id
	 				
	 						
	 			
	 			--select * from #Emp_Cons_temp	 
	 	----------------------------For Old Company Leave detail-------------------------
	 	
	 --	Select  lt.Emp_ID as Old_Emp_Id,lt.Cmp_ID as Old_Cmp_ID, lt.Leave_ID AS Old_Leave_Id,lm.Leave_Name as Old_Leave_Name,Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End as Old_Balance  
		--From    T0140_LEave_Transaction lt inner join 
		
		--		(select    max(For_Date)For_Date,Emp_ID,LEave_ID 
		--		 from	    T0140_LEave_Transaction
		--		 where	      For_Date <=@From_Date 
		--		 group by       emp_ID,LeavE_ID )Q 
				 
		--	ON     lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date  inner join 
		--	T0040_leave_master lm on lt.leavE_id =lm.leave_id   Inner Join
		--	#Emp_Cons_temp EC on lt.Emp_Id = EC.Old_Emp_ID		
				
		--Where Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End > 0 
				
		--order by Old_Emp_Id asc
		
	 	
	 	
	 --	SELECT CLT.Emp_Id as Old_Emp_Id,CLT.Cmp_Id as Old_Cmp_ID,-- CLT.Leave_Id AS Old_Leave_Id,OLM.Leave_Name as Old_Leave_Name,CLT.Old_Balance,
		--	   CLT.Emp_Id as Old_Emp_Id,CLT.New_Cmp_Id as New_Cmp_ID,CLT.Leave_Id,NLM.Leave_Name as Old_Leave_Name,CLT.Old_Balance	
		--FROM	T0100_EMP_COMPANY_LEAVE_TRANSFER CLT INNER JOIN
		--		--T0040_LEAVE_MASTER OLM ON CLT.Leave_Id = OLM.Leave_ID INNER JOIN
		--		T0040_LEAVE_MASTER NLM ON CLT.Leave_Id = NLM.Leave_ID INNER JOIN			
		--		#Emp_Cons_temp EC on CLT.Emp_Id = EC.Old_Emp_Id 		 
		----WHERE Clt.Emp_Id in (select emp_id from #Emp_Cons)
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + NLM.Leave_Name, 500)
			
		
		
		Select lt.Emp_ID as Old_Emp_Id,lt.Cmp_ID as Old_Cmp_ID, lt.Leave_ID AS Old_Leave_Id,lm.Leave_Name as Old_Leave_Name,Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End as Old_Balance  
		From  T0140_LEave_Transaction lt WITH (NOLOCK) inner join 
			(select max(For_Date)For_Date,Emp_ID,LEave_ID from T0140_LEave_Transaction WITH (NOLOCK)
				where(emp_ID IN (select Emp_ID From #Emp_Cons) And For_Date <=@From_Date) 
				group by emp_ID,LeavE_ID )Q on lt.emp_ID =q.emp_ID and lt.leave_ID =q.leavE_ID and lt.for_Date =q.for_Date inner join 
				T0040_leave_master lm WITH (NOLOCK) on lt.leavE_id =lm.leave_id Inner Join
				#Emp_Cons_temp EC on lt.Emp_Id = EC.Old_Emp_Id 
		--#Emp_Cons EC on lt.Emp_Id = EC.Emp_ID
		Where Case When Leave_Posting > 0 Then Leave_Posting Else Leave_Closing End > 0 
		order by Leave_Name asc
		
		----------------------------For New Company Leave detail-------------------------
		
		SELECT CLT.Emp_Id as Old_Emp_Id,CLT.Cmp_Id as Old_Cmp_ID,-- CLT.Leave_Id AS Old_Leave_Id,OLM.Leave_Name as Old_Leave_Name,CLT.Old_Balance,
			   CLT.New_Emp_Id as New_Emp_Id,CLT.New_Cmp_Id as New_Cmp_ID,CLT.New_Leave_Id,NLM.Leave_Name as New_Leave_Name,CLT.New_Balance	
		FROM	T0100_EMP_COMPANY_LEAVE_TRANSFER CLT WITH (NOLOCK) INNER JOIN
				--T0040_LEAVE_MASTER OLM ON CLT.Leave_Id = OLM.Leave_ID INNER JOIN
				T0040_LEAVE_MASTER NLM WITH (NOLOCK) ON CLT.New_Leave_Id = NLM.Leave_ID INNER JOIN
				#Emp_Cons_temp EC on CLT.New_Emp_Id = EC.New_Emp_ID 
		--WHERE CLT.Cmp_Id = @Cmp_Id			
		ORDER BY RIGHT(REPLICATE(N' ', 500) + NLM.Leave_Name, 500) 
		
		--added jimit 23112015
		--SELECT CLT.Emp_Id as Old_Emp_Id,CLT.Cmp_Id as Old_Cmp_ID,-- CLT.Leave_Id AS Old_Leave_Id,OLM.Leave_Name as Old_Leave_Name,CLT.Old_Balance,
		--	   CLT.New_Emp_Id as New_Emp_Id,CLT.New_Cmp_Id as New_Cmp_ID,CLT.New_Leave_Id,NLM.Leave_Name as New_Leave_Name,CLT.New_Balance	
		--FROM	T0100_EMP_COMPANY_LEAVE_TRANSFER CLT INNER JOIN
		--		--T0040_LEAVE_MASTER OLM ON CLT.Leave_Id = OLM.Leave_ID INNER JOIN
		--		T0040_LEAVE_MASTER NLM ON CLT.New_Leave_Id = NLM.Leave_ID --INNER JOIN
							
		----WHERE EM.Alpha_Emp_code in (select alpha_emp_code from #Alpha_Emp_Cons)	
		----ORDER BY RIGHT(REPLICATE(N' ', 500) + EM.Alpha_Emp_Code, 500)
		--ended
		
		drop TABLE #temp
		
		
		
	RETURN

