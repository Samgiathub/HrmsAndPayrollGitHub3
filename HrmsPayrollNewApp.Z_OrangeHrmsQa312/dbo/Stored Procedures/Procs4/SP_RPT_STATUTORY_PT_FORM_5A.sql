
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PT_FORM_5A]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_call	varchar(20) ='PT Statement'
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

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric,
		Branch_ID numeric(18,0)
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons (Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 


			UPDATE	@Emp_Cons
			SET		BRANCH_ID = I.BRANCH_ID
			FROM	@Emp_Cons E INNER JOIN (
												SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID
												FROM	T0095_INCREMENT I1 WITH (NOLOCK)
												WHERE	I1.Increment_ID=(
																			SELECT	MAX(INCREMENT_ID)
																			FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																			WHERE	I2.Increment_Effective_Date = (
																													SELECT	MAX(INCREMENT_EFFECTIVE_DATE)
																													FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																													WHERE	I3.Emp_ID=I2.Emp_ID 
																															AND Increment_Effective_Date <= @To_Date
																												   )
																					AND I2.Emp_ID=I1.Emp_ID
																		)
											) I ON E.EMP_ID=I.Emp_ID

		end
	else
		begin
			
			
			Insert Into @Emp_Cons

			select I.Emp_Id,I.Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
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
Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  
  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING  WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
       
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	   set @Sal_St_Date = cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   set @From_Date = @Sal_St_Date
	   Set @To_Date = @Sal_end_Date   
	End 


	if @Report_Call ='PT Statement'
		begin
			Select ms.Emp_Id,MS.Pt_Calculated_Amount,Ms.PT_Amount,Emp_full_Name,Grd_Name,Month(Month_End_Date)as Month,YEar(Month_End_Date)as Year 
					,EMP_CODE,Type_Name,Dept_Name,Desig_Name ,CMP_NAME,CMP_ADDRESS,PT_F_T_Limit,Comp_Name,Branch_Address,Branch_name,BM.Branch_ID		
				 From T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join 
				T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN 
					@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
					T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID 
					inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  INNER JOIN 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID
				WHERE E.Cmp_ID = @Cmp_Id	
					and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date 
					and PT_Amount > 0
				
		End
	else
		Begin
		
						 Declare @PT_Challan Table
							  ( 
  								Cmp_ID		numeric ,
								Branch_ID 		numeric ,
								PT_L_T_Limit  	varchar(50),
								A_PT_Amount		numeric(18,2) default 0,
								PT_Amount		numeric(18,2) default 0,
								P_month		numeric ,
								P_Year		numeric,
								PT_calculated_Amount  numeric	default 0,
								Emp_Count	numeric default 0 ,
								PT_NA       numeric default 0,
								Total_PT    numeric default 0
								
							  )	
							  
				
				--Added By Jimit 19102019
				Declare @MultiBranch as varchar(max)
				Declare @State_Name varchar(50)
				set @State_Name = 0
				If Isnull(@MultiBranch,'0') = '0' 
				BEGIN
					Declare CurBranch cursor Fast_forward for	                  
						SELECT DISTINCT Branch_Id From @Emp_Cons
					Open CurBranch                      
				END
				Fetch next from CurBranch into @branch_Id
				While @@fetch_status = 0                    
					Begin  
						
						SET @State_Name = 0
								
						SELECT @State_Name = SM.State_Name FROM T0030_BRANCH_MASTER BM WITH (NOLOCK) INNER JOIN T0020_STATE_MASTER SM WITH (NOLOCK) ON BM.State_ID = SM.State_ID
						WHERE Branch_ID = @branch_Id and BM.Cmp_ID = @cmp_ID
						
						IF ISNULL(@State_Name,0) = 'Maharashtra'	
							BEGIN															
									insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
									select	/*distinct*/ p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END  ,Month(@To_Date) ,year(@To_Date)
									from	T0040_professional_setting p WITH (NOLOCK)
											inner join (
														 select max(for_Date)For_Date ,Branch_ID 
														 from	T0040_professional_setting WITH (NOLOCK)
														 where	Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      
														 group by branch_ID 
														) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
									Where p.Cmp_Id =@Cmp_ID and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
							END
						ELSE	
							BEGIN
								insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
								select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END  ,Month(@To_Date) ,year(@To_Date)
								from	T0040_professional_setting p WITH (NOLOCK)
										inner join (
													 select max(for_Date)For_Date ,Branch_ID 
													 from	T0040_professional_setting WITH (NOLOCK)
													 where	Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date   
													 group by branch_ID
													) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
								Where	p.Cmp_Id =@Cmp_ID 
										and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
							END 							
						--insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year,cHALLAN_ID,From_Limit ,To_Limit)
						--select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  cast(To_Limit as varchar(20))  ,Month(@To_Date) ,year(@To_Date),@Challan_ID_temp
						--			,From_Limit ,To_Limit
						--from T0040_professional_setting p inner join 
						--( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting 
						--	where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
						--group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
						--Where p.Cmp_Id =@Cmp_ID 
						--and isnull(P.Branch_ID,0) = @branch_Id-- isnull(q.Branch_ID,0)						
						
				fetch next from CurBranch into @branch_Id
					end                    
			close CurBranch                    
			deallocate CurBranch
				--Ended
									
			---changed By Jimit 12072018 for Gallops as slabs must fetch according to State wise not branch wise		  
				--insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
				--select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  cast(To_Limit as varchar(20))  ,Month(@To_Date) ,year(@To_Date)
				--from			T0040_professional_setting p inner join 
				--				( 
				--					select	max(for_Date)For_Date,bm.State_ID 
				--					  from		T0040_professional_setting PT INNER JOIN
				--								T0030_BRANCH_MASTER BM  On bm.Branch_ID = Pt.Branch_ID INNER JOIN
				--								T0020_STATE_MASTER SM On Sm.State_ID = Bm.State_ID --and Sm.Loc_ID = Bm.Branch_ID
				--					  where		bm.Cmp_ID =@cmp_ID and 
				--								(bm.Branch_ID = ISNULL(@Branch_ID,bm.Branch_ID) or isnull(bm.Branch_ID,0) = 0 )
				--								and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
				--					  group by	BM.State_ID
				--				 ) q on p.For_Date = q.for_Date --and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
				--Where p.Cmp_Id =@Cmp_ID --and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)


				--insert into @PT_Challan (Cmp_Id,Branch_Id,A_PT_Amount,PT_L_T_Limit,P_Month,P_Year)
				--select distinct p.Cmp_ID,p.Branch_ID ,Amount ,cast(From_Limit as varchar(20)) + '-' +  Case When Cast(p.To_Limit as VARCHAR(20)) like '999%' Then 'To Above' ELSE cast(To_Limit as varchar(20)) END  ,Month(@To_Date) ,year(@To_Date)
				--from T0040_professional_setting p inner join 
				--( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting 
				--	where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID) or isnull(Branch_ID,0) = 0 ) and For_Date <= @To_Date      --add branch_Id,For_date condition Mihir 06092011 -- branch condition altered by mitesh on 23072012
				--group by branch_ID
				--) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
				--Where p.Cmp_Id =@Cmp_ID 
				--and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)

				

				---changed By Jimit 12072018 for Gallops as slabs must fetch according to State wise not branch wise
					update	@PT_Challan 
					set		PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
					From	@PT_Challan  P 
							inner join 	(
											Select BM.State_ID,count(ms.emp_Id)Emp_Count,PT_Amount,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount ) sum_PT_calculated_Amount ,BM.Branch_ID
											From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join 
													--T0095_Increment I WITH (NOLOCK) on ms.Increment_ID =i.Increment_ID inner join 
													@emp_Cons ec on ms.emp_ID = ec.emp_ID INNER JOIN
													T0030_BRANCH_MASTER BM  WITH (NOLOCK) On bm.Branch_ID = ec.Branch_ID INNER JOIN
													T0020_STATE_MASTER SM WITH (NOLOCK) On Sm.State_ID = Bm.State_ID
											Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date
											group by BM.State_ID ,PT_Amount,BM.Branch_ID
										) q on  p.A_PT_Amount = q.PT_Amount and p.Branch_ID =q.Branch_ID
					Where	isnull(p.Branch_ID,0) > 0 				

			 		update	@PT_Challan 
					set		PT_Amount = q.Sum_PT_Amount ,
							PT_calculated_Amount = q.sum_PT_calculated_Amount,
							Emp_Count = q.Emp_Count
					From	@PT_Challan  P
							inner join (
											Select	PT_Amount,count(ms.emp_Id)Emp_Count,sum(PT_Amount) Sum_PT_Amount,Sum(PT_calculated_Amount) sum_PT_calculated_Amount 
											From	T0200_MONTHLY_SALARY ms WITH (NOLOCK)
													inner join T0095_Increment I WITH (NOLOCK) on ms.Increment_ID =i.Increment_ID 
													inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
											Where Month_St_date >= @From_Date and Month_End_Date <= @To_Date
											group by PT_Amount
										) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = q.PT_Amount
					Where  isnull(p.Branch_ID,0) =0
				
				
					update	@PT_Challan 
					set		PT_NA = q.PT_NA
					From	@PT_Challan  P 
							inner join (
											Select	count(ms.Emp_ID) PT_NA 
											From	T0200_MONTHLY_SALARY ms WITH (NOLOCK)
													inner join T0095_Increment I WITH (NOLOCK) on ms.Increment_ID =i.Increment_ID 
													inner join @emp_Cons ec on ms.emp_ID = ec.emp_ID 
											Where Month_St_date >=@From_Date and Month_End_Date <=@To_Date
											group by PT_Amount
										) q on isnull(p.Branch_ID,0) =0 and p.A_PT_Amount = 0
					Where  isnull(p.Branch_ID,0) =0
				
					select	p.* ,Branch_NAme,Cmp_Phone,Cmp_Address,Cmp_Name,@From_Date as Month_Start_Date,
							@To_Date as Month_End_Date,
							(
								select	[dbo].[F_Number_TO_Word](sum(PT_Amount)) 
								from	@PT_Challan
							) as Total_PT_inWord ,BM.Branch_ID 
							,BM.PT_RC_No -- Added By Sajid 14-09-2021
							,BM.Branch_City  -- Added By Sajid 05-01-2022 For P.T.O. Circle No.
							,upper(sm.State_Name) State_Name --Added by ronakk 12052023
					from	@PT_Challan	p 
							left outer Join T0030_Branch_MAster bm WITH (NOLOCK) on p.Branch_ID = bm.Branch_ID
							left outer Join T0020_STATE_MASTER sm WITH (NOLOCK) on  bm.State_ID = sm.State_ID --Added by ronakk 12052023
							Inner join T0010_COMPANY_MASTER CM  WITH (NOLOCK) on p.Cmp_Id = cm.Cmp_ID 
			
			-- In Above Select after Cmp_Name fields added by Mihir 06092011	

			
		End			
RETURN




