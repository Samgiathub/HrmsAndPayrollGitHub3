
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_EMP_WITH_REPORTING_MANAGER]  
	@Cmp_Id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
 declare @Year_End_Date as datetime  
 Declare @User_type varchar(30)  
   
   
  
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
	 If @Type_ID = 0  
		set @Type_ID = null 	
 
     
   
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
			Insert Into @Emp_Cons

				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_Id
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID
					Where E.CMP_ID = @Cmp_Id 
					and isnull(i.BRANCH_ID,0) = isnull(@BRANCH_ID ,isnull(i.BRANCH_ID,0))
					and isnull(i.Type_ID,0) = isnull(@Type_ID ,isnull(i.Type_ID,0))-- Added by Mitesh on 06/09/2011
					and isnull(i.Grd_ID,0) = isnull(@Grade_ID ,isnull(i.Grd_ID,0))
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))	
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Cmp_Id   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
		END

		SELECT EM.CMP_ID,EM.EMP_ID,EM.ALPHA_EMP_CODE,EM.EMP_FULL_NAME, 
			(
				SELECT DISTINCT CONVERT(NVARCHAR(500),
				REM.ALPHA_EMP_CODE + ' - ' + REM.EMP_FULL_NAME + ' - ' + CM.CMP_NAME ) + ' , '  
				FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
				INNER JOIN  ( 
								SELECT EMP_ID , MAX(EFFECT_DATE) AS EFFECT_DATE 
								FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
								WHERE	 EFFECT_DATE <= GETDATE()
								GROUP BY Emp_ID	
							)MAX_RPT ON MAX_RPT.Emp_ID = RD.Emp_ID AND MAX_RPT.EFFECT_DATE = RD.Effect_Date
				INNER JOIN T0080_EMP_MASTER REM WITH (NOLOCK) ON REM.EMP_ID = RD.R_EMP_ID
				INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON REM.CMP_ID = CM.CMP_ID
				WHERE RD.EMP_ID = EM.EMP_ID
				FOR XML PATH('')
			) AS REPORTING_MANAGER,
		TI.BRANCH_ID,TI.DESIG_ID,TI.DEPT_ID,TI.GRD_ID,TI.Vertical_ID,ti.SubVertical_ID,
		TI.Cat_ID,TI.SalDate_id as SalCycleId,TI.Segment_ID,TI.subBranch_ID,TI.Band_Id,TI.Type_ID --Added by Ronakk 10022022
		 FROM @EMP_CONS EC
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID
		inner join t0095_increment TI WITH (NOLOCK) on em.emp_id =TI.emp_id and em.increment_id =TI.increment_id
		ORDER BY RIGHT(REPLICATE(N' ', 500) + EM.ALPHA_EMP_CODE, 500) 
		
		return


