

--=============================================================================================================
--Created BY   : Sumit
--Created DATE : 30-Apr-2015
--DESCRIPTION : ALTER CTC WISE SALARY REPORTS
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--=============================================================================================================
CREATE PROCEDURE [dbo].[SP_EMP_INCREMENT_REPORT]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC   = 0
	,@Cat_ID		NUMERIC  = 0
	,@Grd_ID		NUMERIC = 0
	,@Type_ID		NUMERIC  = 0
	,@Dept_ID		NUMERIC  = 0
	,@Desig_ID		NUMERIC = 0
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	IF @Branch_ID = 0
		SET @Branch_ID = NULL
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Dept_ID = 0
		SET @Dept_ID = NULL
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
	If @Desig_ID = 0
		SET @Desig_ID = NULL
		
	
	
	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO @Emp_Cons
			SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			
			
			INSERT INTO @Emp_Cons

			SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
					(SELECT MAX(Increment_effective_Date) AS For_Date , Emp_ID FROM T0095_Increment WITH (NOLOCK) 
					WHERE Increment_Effective_date <= @To_Date
					AND Cmp_ID = @Cmp_ID
					GROUP BY emp_ID  ) Qry ON
					I.Emp_ID = Qry.Emp_ID	AND I.Increment_effective_Date = Qry.For_Date
			WHERE Cmp_ID = @Cmp_ID 
			AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))
			AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)
			AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
			AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))
			AND ISNULL(Type_ID,0) = ISNULL(@Type_ID ,ISNULL(Type_ID,0))
			AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
			AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in 
				(SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE cmp_ID = @Cmp_ID   AND  
				(( @From_Date  >= join_Date  AND  @From_Date <= left_date ) 
				OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )
				OR Left_date IS NULL  AND @To_Date >= Join_Date)
				OR @To_Date >= left_date  AND  @From_Date <= left_date ) 
			
		END
		
		declare @FinYear as nvarchar(20)
		if MONTH(GetDate()) > 3
			set @FinYear = Convert(nvarchar,YEAR(Getdate())) + '-' + convert(nvarchar,(YEAR(Getdate()) + 1))
		else
			set @FinYear = Convert(nvarchar,(YEAR(Getdate()) - 1)) + '-' + convert(nvarchar,YEAR(Getdate()))
	
	
		SELECT I_Q.* ,I_Q.Gross_Salary,Cmp_Name,Cmp_address,BM.Comp_Name,BM.Branch_Address,Emp_Code, E.Alpha_Emp_Code
					,E.Emp_First_Name,E.Mobile_No,E.Work_Email,CTM.Cat_Name    
					--,E.Emp_Full_Name 
					,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,I_Q.Basic_Salary,I_Q.Increment_Effective_Date,I_Q.Pre_Gross_Salary,I_Q.Increment_Amount,I_Q.Increment_Type
					, @FinYear  as financial_Year  
					,E.Pan_No 
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					INNER JOIN T0010_Company_Master CM WITH (NOLOCK) on
					Cm.Cmp_Id =E.Cmp_ID INNER JOIN t0095_increment I_Q WITH (NOLOCK) on e.Emp_ID = I_Q.Emp_ID inner join 
					 ( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment  WITH (NOLOCK)
					 where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on  
					 I_Q.Emp_ID = Qry.Emp_ID and I_Q.Increment_ID = Qry.Increment_ID		INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID				LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID			LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0030_CATEGORY_MASTER CTM WITH (NOLOCK) On I_Q.Cat_ID = CTM.Cat_ID LEFT OUTER JOIN	-- Added By Gadriwala 17022014
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id		INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
		WHERE E.Cmp_ID = @Cmp_Id	
				AND E.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		
		create table #Emp_Inc
		(
		Emp_id numeric(18,0),
		Ad_Id numeric(18,0),
		Ad_Name varchar(50)--,
		--Ad_Amount numeric(18,2),		
		--Increment_id numeric(18,0)
		)
		
		Insert into #Emp_Inc
		select distinct I.Emp_id,EAD.AD_ID,Ad_name from T0050_AD_MASTER am WITH (NOLOCK)
			inner join T0100_EMP_EARN_DEDUCTION EAD WITH (NOLOCK) on am.AD_ID=EAD.AD_ID and am.CMP_ID=EAD.CMP_ID
			inner join t0095_increment i WITH (NOLOCK) on i.Emp_ID=EAD.Emp_id inner join
				 (select top 2 Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK) 
					 where Increment_Effective_date between @From_Date and @to_date
					 and Cmp_ID = @cmp_id 
					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
					  group by emp_ID,Increment_ID order by increment_id desc
					  ) Qry on  
					 i.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
					 and EAD.INCREMENT_ID=Qry.Increment_ID
					 left outer join T0080_emp_master EM WITH (NOLOCK) on Em.Emp_ID=I.emp_id
		WHERE I.Cmp_ID = @Cmp_Id
		AND I.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 
		
		declare @qry as varchar(max)
		
		Set @qry = 'Alter table #Emp_inc add Increment_Date_1 Datetime'
		exec (@Qry)		
		
		Set @qry = 'Alter table #Emp_inc add Increment_1 Numeric(18,2)'
		exec (@Qry)

		Set @qry = 'Alter table #Emp_inc add Increment_Date_2 Datetime'
		exec (@Qry)		

		Set @qry = 'Alter table #Emp_inc add Increment_2 Numeric(18,2)'
		exec (@Qry)		



--Update #Emp_Inc Set Increment_Date_1 = Increment_Effective_Date, Increment_1 = ead.E_AD_AMOUNT 
--From #Emp_Inc EI Inner Join
-- T0100_EMP_EARN_DEDUCTION EAD on EI.Emp_id=Ead.Emp_Id and EI.Ad_Id = Ead.AD_Id inner join 
--T0050_AD_MASTER am on am.AD_ID=EAD.AD_ID and am.CMP_ID=EAD.CMP_ID
--			inner join t0095_increment i on i.Emp_ID=EAD.Emp_id inner join
--			(select top 1 Increment_ID ,Emp_ID From T0095_Increment 				   
--					 where Increment_Effective_date between @From_Date and @to_date
--					 and Cmp_ID = @cmp_id 
--					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
--					  group by emp_ID,Increment_ID 
--					  order by increment_id desc
--					  ) Qry on  
--					 i.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
--					 and EAD.INCREMENT_ID=Qry.Increment_ID 
--					 inner join @Emp_Cons ecn on ecn.Emp_ID=Qry.emp_id
--					 left outer join T0080_emp_master EM on Em.Emp_ID=I.emp_id
--		WHERE I.Cmp_ID = @Cmp_Id
--		AND I.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 
		
		
		
Update #Emp_Inc Set Increment_Date_1 = Increment_Effective_Date, Increment_1 = ead.E_AD_AMOUNT 
From #Emp_Inc EI Inner Join
 T0100_EMP_EARN_DEDUCTION EAD on EI.Emp_id=Ead.Emp_Id and EI.Ad_Id = Ead.AD_Id inner join 
T0050_AD_MASTER am on am.AD_ID=EAD.AD_ID and am.CMP_ID=EAD.CMP_ID
			inner join t0095_increment i on i.Emp_ID=EAD.Emp_id inner join
			(select max(Increment_ID)as Increment_ID , Emp_ID From T0095_Increment 	WITH (NOLOCK)			   
					 where Increment_Effective_date between @From_Date and @to_date
					 and Cmp_ID = @cmp_id 
					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
					  group by emp_ID--,Increment_ID 
					  --order by increment_id desc
					  ) Qry on  
					 i.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
					 and EAD.INCREMENT_ID=Qry.Increment_ID 
					 --inner join @Emp_Cons ecn on ecn.Emp_ID=Qry.emp_id
					 left outer join T0080_emp_master EM WITH (NOLOCK) on Em.Emp_ID=I.emp_id
		WHERE I.Cmp_ID = @Cmp_Id
		AND I.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 



--Update #Emp_Inc Set Increment_Date_2 = Increment_Effective_Date, Increment_2 = ead.E_AD_AMOUNT 
--From #Emp_Inc EI Inner Join
-- T0100_EMP_EARN_DEDUCTION EAD on EI.Emp_id=Ead.Emp_Id and EI.Ad_Id = Ead.AD_Id inner join
--T0050_AD_MASTER am on am.AD_ID=EAD.AD_ID and am.CMP_ID=EAD.CMP_ID
			
--			inner join t0095_increment i on i.Emp_ID=EAD.Emp_id inner join
--				 (select top 1 Increment_ID , Emp_ID From T0095_Increment  
--					 where Increment_Effective_date between @From_Date and @to_date
--					 and Cmp_ID = @cmp_id 
--					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
--					 And Increment_Id not in (
--					 select top 1 Increment_ID From T0095_Increment  
--					 where Increment_Effective_date between @From_Date and @to_date
--					 and Cmp_ID = @cmp_id 
--					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
--					  group by emp_ID
--					  ,Increment_ID 
--					  order by increment_id desc
					 
--					 )
--					  group by emp_ID,Increment_ID 
--					  order by increment_id desc
--					  ) Qry on  
--					 i.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
--					 and EAD.INCREMENT_ID=Qry.Increment_ID
--					 left outer join T0080_emp_master EM on Em.Emp_ID=I.emp_id
--		WHERE I.Cmp_ID = @Cmp_Id
--		AND I.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 		

Update #Emp_Inc Set Increment_Date_2 = Increment_Effective_Date,Increment_2 = ead.E_AD_AMOUNT 
From #Emp_Inc EI Inner Join
 T0100_EMP_EARN_DEDUCTION EAD on EI.Emp_id=Ead.Emp_Id and EI.Ad_Id = Ead.AD_Id inner join
T0050_AD_MASTER am on am.AD_ID=EAD.AD_ID and am.CMP_ID=EAD.CMP_ID
			
			inner join t0095_increment i on i.Emp_ID=EAD.Emp_id inner join
				 (select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment  WITH (NOLOCK)
					 where Increment_Effective_date between @From_Date and @to_date
					 and Cmp_ID = @cmp_id 
					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
					 And Increment_Id not in (
					 select max(Increment_ID) as Increment_ID From T0095_Increment WITH (NOLOCK) 
					 where Increment_Effective_date between @From_Date and @to_date
					 and Cmp_ID = @cmp_id 
					 AND Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
					  group by emp_ID
					  --,Increment_ID 
					  --order by increment_id desc
					 
					 )
					  group by emp_ID--,Increment_ID 
					  --order by increment_id desc
					  ) Qry on  
					 i.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
					 and EAD.INCREMENT_ID=Qry.Increment_ID
					 left outer join T0080_emp_master EM WITH (NOLOCK) on Em.Emp_ID=I.emp_id
		WHERE I.Cmp_ID = @Cmp_Id
		AND I.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons) 		
		

		
		select distinct * from #Emp_Inc
		
		drop table #Emp_Inc
		
		
		
		
RETURN




