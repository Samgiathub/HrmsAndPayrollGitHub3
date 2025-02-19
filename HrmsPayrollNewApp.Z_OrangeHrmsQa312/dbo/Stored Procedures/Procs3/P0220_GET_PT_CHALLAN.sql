

-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <27/07/2012>
-- Description:	<Developed for PT Challan>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0220_GET_PT_CHALLAN]
	@Cmp_ID 	Numeric
   ,@Emp_ID     Numeric = 0
   ,@Month 	    Numeric
   ,@Year 	    Numeric
   --,@Branch_ID 	Numeric
   ,@Branch_ID  varchar(max) = '' --Added By Jaina 18-09-2015
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @From_Date Datetime
	Declare @To_Date Datetime
	
		Select @From_Date = dbo.GET_MONTH_ST_DATE(@Month, @Year)
		Select @To_Date = dbo.GET_MONTH_END_DATE(@Month, @Year)
		
	IF @Branch_ID = '0'  or @Branch_Id = ''
		Set @Branch_ID = null
		
	IF @Emp_ID = 0
		Set @Emp_ID  = Null	
		
		Declare @Emp_Cons Table
		(
			Emp_ID	numeric(18,0),
			Branch_ID numeric(18,0)  --Added By Jaina 10-02-2016
		)
	
		If @Emp_ID IS NOT NULL
			BEGIN
				Insert Into @Emp_Cons(Emp_ID)
				select  @Emp_ID
			END
		Else
			BEGIN
				--comment By Jaina 11-02-2016
				--Insert Into @Emp_Cons
				--SELECT	I.Emp_Id 
				--FROM	T0095_Increment I INNER JOIN T0200_MONTHLY_SALARY MS ON I.Increment_ID=MS.Increment_ID AND I.Cmp_ID=MS.Cmp_ID
				--		INNER JOIN (SELECT	Cast(data as numeric) as Branch_ID 
				--					FROM	dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=I.Branch_ID --Added By Jaina 18-09-2015 			 					
				--WHERE	I.Cmp_ID = @Cmp_ID and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 						
				--		AND Month(Month_End_date) >= Month(@TO_Date) And Year(Month_End_date) >= Year(@TO_Date)	--Ankit 25122014 
				--		and Month(Month_End_Date) <=Month(@To_Date) and Year(Month_End_Date) <=Year(@To_Date)	--Ankit 25122014
				--		and PT_Amount > 0
				--		and I.Emp_ID in ( select Emp_Id from (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
				--				where cmp_ID = @Cmp_ID   and  
				--				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				--				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				--				or Left_date is null and @To_Date >= Join_Date)
				--				or @To_Date >= left_date  and  @From_Date <= left_date )
				
				--Added By Jaina 11-02-2016
				Insert Into @Emp_Cons (Emp_ID,Branch_ID)
				 select distinct I.Emp_Id,I.Branch_ID
				  from T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				INNER JOIN (
								SELECT	EMP_ID, INCREMENT_ID, BRANCH_ID,I1.Cmp_ID
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
							) I ON MS.EMP_ID=I.Emp_ID
				INNER JOIN (SELECT	Cast(data as numeric) as Branch_ID 
									FROM	dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=I.Branch_ID --Added By Jaina 18-09-2015 			 					
				WHERE	I.Cmp_ID = @Cmp_ID and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 						
						AND Month(Month_End_date) >= Month(@TO_Date) And Year(Month_End_date) >= Year(@TO_Date)	--Ankit 25122014 
						and Month(Month_End_Date) <=Month(@To_Date) and Year(Month_End_Date) <=Year(@To_Date)	--Ankit 25122014
						and PT_Amount > 0
						and I.Emp_ID in ( select Emp_Id from (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
								where cmp_ID = @Cmp_ID   and  
								(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )
								or Left_date is null and @To_Date >= Join_Date)
								or @To_Date >= left_date  and  @From_Date <= left_date )
								
				
				--SELECT	I.Emp_Id 
				--FROM	T0095_Increment I 
				--		INNER JOIN (SELECT	Cast(data as numeric) as Branch_ID 
				--					FROM	dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=I.Branch_ID --Added By Jaina 18-09-2015 			 					
				--		INNER JOIN (SELECT Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
				--					FROM	t0095_increment TI 
				--							INNER JOIN (
				--										SELECT	Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID 
				--										FROM	T0095_Increment
				--										Where	Increment_effective_Date <= @to_date 
				--										Group by emp_ID
				--										) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				--					Where	TI.Increment_effective_Date <= @to_date 
				--					group by ti.emp_id
				--					) Qry on I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
				--WHERE	Cmp_ID = @Cmp_ID and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
				--		and I.Emp_ID in ( select Emp_Id from (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
				--	where cmp_ID = @Cmp_ID   and  
				--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				--	or Left_date is null and @To_Date >= Join_Date)
				--	or @To_Date >= left_date  and  @From_Date <= left_date )
			END
			
	
	Declare @PT_Challan Table
	 ( 
  		Cmp_ID		Numeric,
		--Branch_ID 	Numeric,		
		Branch_ID 	varchar(max),	
		PT_Amount	Numeric(18,2) Default 0,
		P_month		Numeric,
		P_Year		Numeric,		
		Emp_Count	Numeric Default 0		
	 )	
			
		IF @Branch_ID IS NOT NULL
			BEGIN				
			
--				SELECT * FROM T0040_professional_setting as t1
--INNER JOIN 
--(Select Cast(data as numeric) as Branch_ID FROM dbo.Split('232','#')) T ON T.Branch_ID=t1.Branch_ID --Added By Jaina 18-09-2015 			 
--inner join
--(select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting 
--					where Cmp_ID =55 AND Branch_ID=232
--GROUP BY  Branch_ID) as q on q.For_Date = t1.For_Date
-- WHERE Cmp_ID = 55 AND t1.Branch_ID=232				
 
 

				Insert into @PT_Challan (Cmp_Id, Branch_Id, P_Month, P_Year)
				--select distinct p.Cmp_ID, p.Branch_ID , @Month , @Year
				select distinct p.Cmp_ID, T.Branch_ID, @Month , @Year
				from T0040_professional_setting p WITH (NOLOCK) INNER JOIN 
				(Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=Isnull(p.Branch_ID,T.Branch_ID) --Added By Jaina 18-09-2015 			 
				INNER JOIN
				( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting  WITH (NOLOCK)
					where Cmp_ID =@cmp_ID 
					--and (Branch_ID = ISNULL(@Branch_ID,Branch_ID)) 
					and For_Date <= @To_Date
					group by branch_ID) q on p.For_Date = q.for_Date --and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0) Jaina 18-09-2015
					Where p.Cmp_Id =@Cmp_ID --and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0) Jaina 18-09-2015
				
				
			
			END				  
		
		ELSE
			BEGIN
				Insert into @PT_Challan (Cmp_Id, Branch_Id, P_Month, P_Year)
				select distinct p.Cmp_ID, 0 , @Month , @Year
				from T0040_professional_setting p WITH (NOLOCK) INNER JOIN 
				( select max(for_Date)For_Date ,Branch_ID from T0040_professional_setting WITH (NOLOCK)
					where Cmp_ID =@cmp_ID and (Branch_ID = ISNULL(@Branch_ID,Branch_ID)) and For_Date <= @To_Date
					group by branch_ID) q on p.For_Date = q.for_Date and isnull(p.Branch_ID,0) = isnull(q.Branch_ID,0)
					Where p.Cmp_Id =@Cmp_ID and isnull(P.Branch_ID,0) = isnull(q.Branch_ID,0)
			END

		
		If @Branch_ID IS NOT NULL
			BEGIN	
						
				update @PT_Challan 
				set PT_Amount = q.Sum_PT_Amount ,					
				Emp_Count = q.Emp_Count
				From @PT_Challan  P INNER JOIN 
					( Select sum(PT_Amount) Sum_PT_Amount,Branch_Id,count(ms.emp_Id)Emp_Count  --add T.Branch_id replace Branch_id
					From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) --INNER JOIN T0095_Increment I on ms.Increment_ID =i.Increment_ID --Comment By Jaina 11-02-2016
					--INNER JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=I.Branch_ID --Added By Jaina 18-09-2015 			 						
					INNER JOIN @emp_Cons ec on ms.emp_ID = ec.emp_ID 					
					Where --Month_St_date >=@From_Date and Month_End_Date <=@To_Date 
						Month(Month_End_date) >= Month(@TO_Date) And Year(Month_End_date) >= Year(@TO_Date)	--Ankit 25122014 
						and Month(Month_End_Date) <=Month(@To_Date) and Year(Month_End_Date) <=Year(@To_Date)	--Ankit 25122014
						and PT_Amount > 0
					group by Branch_ID ) q on p.Branch_ID =q.Branch_ID 
				Where  ISNULL(p.Branch_ID,0) > 0 
			END
		Else
			BEGIN
				update @PT_Challan 
				set PT_Amount = q.Sum_PT_Amount ,					
				Emp_Count = q.Emp_Count,
				Branch_ID = 0 
				From @PT_Challan  P INNER JOIN 
					( Select sum(PT_Amount) Sum_PT_Amount,count(ms.emp_Id)Emp_Count,ms.Cmp_ID  
					From	T0200_MONTHLY_SALARY ms WITH (NOLOCK) --INNER JOIN T0095_Increment I on ms.Increment_ID =i.Increment_ID  --Comment By Jaina 11-02-2016
					INNER JOIN @emp_Cons ec on ms.emp_ID = ec.emp_ID 						
					Where --Month_St_date >=@From_Date and Month_End_Date <=@To_Date 
						Month(Month_End_date) >= Month(@TO_Date) And Year(Month_End_date) >= Year(@TO_Date)	--Ankit 25122014 
						and Month(Month_End_Date) <=Month(@To_Date) and Year(Month_End_Date) <=Year(@To_Date)	--Ankit 25122014
						and PT_Amount > 0 group by ms.Cmp_ID)q on p.Cmp_ID =q.Cmp_ID 				
			END
		
		--Comment By Jaina 18-09-2015
		--Select p.* ,@From_Date as Month_Start_Date,
		--	@To_Date as Month_End_Date,(select [dbo].[F_Number_TO_Word](sum(PT_Amount)) from @PT_Challan) as Total_PT_inWord 
		--from @PT_Challan p 
		
		--	added by Jaina 18-09-2015
		Select P.Cmp_ID,P.P_month,p.P_Year,SUM(PT_Amount)AS PT_Amount ,SUM(Emp_Count) AS Emp_Count,
			   @From_Date as Month_Start_Date,@To_Date as Month_End_Date,(select [dbo].[F_Number_TO_Word](sum(PT_Amount)) from @PT_Challan) as Total_PT_inWord 
		from @PT_Challan p GROUP BY p.Cmp_ID,p.P_month,p.P_Year
		
END
RETURN


