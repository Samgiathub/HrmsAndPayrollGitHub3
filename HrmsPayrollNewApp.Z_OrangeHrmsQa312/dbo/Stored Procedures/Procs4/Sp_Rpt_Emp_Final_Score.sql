



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Rpt_Emp_Final_Score]
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
	,@Appr_Int_Id   Numeric
	,@CONSTRAINT 	VARCHAR(5000)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0  
		Set @Branch_ID = null		
	IF @Cat_ID = 0  
		Set @Cat_ID = null
	IF @Grd_ID = 0  
		Set @Grd_ID = null
	IF @Type_ID = 0  
		Set @Type_ID = null
	IF @Dept_ID = 0  
		Set @Dept_ID = null
	IF @Desig_ID = 0  
		Set @Desig_ID = null
	IF @Emp_ID = 0  
		Set @Emp_ID = null
		
	Declare @Final_Score table
	 (	    
		Emp_ID          Numeric(18,0),		
		For_Date	    DateTime,	
		Title_Name      Varchar(50),		
		Total_Score     Numeric(18,2),
		Eval_Score      Numeric(18,2),
		Total_Score_sup Numeric(18,2),
		Eval_Score_Sup  Numeric(18,2),
		Emp_Status      INT,
		Cmp_ID          Numeric(18,0),   
		Appr_Int_Id     Numeric(18,0)
	 )	 
	 
	 Declare @Emp_ID_Cur  As Numeric(18)
	 Declare @Title_Name  As Varchar(50)
	 Declare @Total_Score As Numeric(18,2)
	 Declare @Eval_Score  As Numeric(18,2)	 
	 Declare @For_Date    As DateTime
	 Declare @Emp_Status  As Int
	 Declare @Cmp_Id_Cur      AS Numeric(18,0)
	 Declare @Appr_Int_Id_Cur As Numeric(18,0)

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

			select I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date								
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
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		End		
				
	  Declare Cur_Emp_Score Cursor For
	  Select Emp_Id,Title_Name,Eval_Score,Emp_Status,Total_Score,For_Date,Cmp_Id,Appr_Int_Id From dbo.T0090_Hrms_Final_Score WITH (NOLOCK) where Cmp_Id=@Cmp_Id order by Emp_Status		
	  Open Cur_Emp_Score
	  Fetch Next From Cur_Emp_Score Into @Emp_ID_Cur,@Title_Name,@Eval_Score,@Emp_Status,@Total_Score,@For_Date,@Cmp_Id_Cur,@Appr_Int_Id_Cur
	  While @@Fetch_Status = 0
	  Begin	  
	  if isnull(@Emp_Status,0) = 0	  
				 Begin
					insert into @Final_Score values(@Emp_ID_Cur,@For_Date,@Title_Name,@Total_Score,@Eval_Score,0,0,@Emp_Status,@Cmp_Id_Cur,@Appr_Int_Id_Cur)
				End			
	  Else If isnull(@Emp_Status,0) = 1
			Begin
				   Update @Final_Score Set Eval_Score_Sup=@Eval_Score,Total_Score_Sup=@Total_Score,For_Date=@For_Date,Emp_Status=@Emp_Status,Cmp_Id=@Cmp_Id_Cur,Appr_Int_Id=@Appr_Int_Id_Cur where Title_Name=@Title_Name And Emp_ID=@Emp_ID_Cur 
			End	  
      Fetch Next From Cur_Emp_Score Into @Emp_ID_Cur,@Title_Name,@Eval_Score,@Emp_Status,@Total_Score,@For_Date,@Cmp_Id_Cur,@Appr_Int_Id_Cur
	  End                      
	  Close Cur_Emp_Score
	Deallocate Cur_Emp_Score 	
				
			Select EM.Emp_Code,EM.Emp_Id,Em.Emp_Full_Name,FS.For_Date,FS.Title_Name,FS.Total_Score,FS.Eval_Score,FS.Total_Score_Sup,FS.Eval_Score_Sup,FS.EMP_Status,CM.Cmp_Name,CM.Cmp_Address,BM.Comp_Name,BM.Branch_Address From @Final_Score FS 
			INNER JOIN dbo.T0080_Emp_Master EM WITH (NOLOCK) ON FS.Emp_Id=EM.Emp_Id
			INNER JOIN dbo.T0030_Branch_Master BM WITH (NOLOCK) ON EM.Branch_Id = BM.Branch_Id
			INNER JOIN dbo.T0010_Company_Master CM WITH (NOLOCK) ON Em.Cmp_Id = CM.Cmp_ID
			Where For_Date >=@From_Date and For_Date <=@To_Date And FS.Cmp_Id=@Cmp_Id And Isnull(Appr_Int_Id,0)= isnull(@Appr_Int_Id,ISNull(FS.Appr_Int_Id,0))
			And EM.Emp_ID in (select Emp_Id from @Emp_Cons) 
		
		
RETURN




