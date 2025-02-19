

-- Created by rohit for Esic form 37
-- created date 28032016
CREATE PROCEDURE [dbo].[RPT_EMP_ESIC_FORM_37_Format1]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		VARCHAR(MAX)
	,@Cat_ID		VARCHAR(MAX)
	,@Grd_ID		VARCHAR(MAX)
	,@Type_ID		VARCHAR(MAX)
	,@Dept_ID		VARCHAR(MAX) 
	,@Desig_ID		VARCHAR(MAX) 
	,@Emp_ID		NUMERIC			= 0
	,@Constraint	VARCHAR(MAX)	= ''
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	
		IF @Branch_ID = ''            
		  SET @Branch_ID = Null          
		      
		IF @Cat_ID = ''           
		  SET @Cat_ID = null          
		       
		IF @Grd_ID = ''            
		  SET @Grd_ID = null          
		       
		IF @Type_ID = ''           
		  SET @Type_ID = null          
		       
		IF @Dept_ID = ''           
		  SET @Dept_ID = null          
		       
		IF @Desig_ID = ''            
		  SET @Desig_ID = null          
		       
		IF @Emp_ID = 0            
		  SET @Emp_ID = null          
		
		  
	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )  
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0    
	
	SELECT Alpha_Emp_Code,SIN_No AS ESIC_NO ,Emp_Full_Name,Father_name,Gender,BM.Branch_Name,
	Replace(Convert(Varchar(15),Date_Of_Birth,106),' ','-') As Date_Of_Join,
	 CM.Cmp_Name + ' ' +  CM.Cmp_Address  As Address,
	 CM.ESIC_No as CODE_No
	 ,isnull(SM.Esic_State_Code,'') as Esic_State_Code
	, isnull(SM.Esic_Reg_Addr,'') as Esic_Reg_Addr
	,CM.Cmp_Name
	FROM T0080_EMP_MASTER EM WITH (NOLOCK) Inner Join
	  --   (SELECT I.Branch_ID,I.Emp_ID FROM T0095_Increment I inner join 
			--	( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment	
			--	where Increment_Effective_date <= @To_Date
			--	group by emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
		 --) Q_I ON EM.EMP_ID = Q_I.EMP_ID Inner JOIN
		 t0095_increment Q_I WITH (NOLOCK) on Em.Emp_ID =Q_I.Emp_ID inner join
		 (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on Q_I.Increment_Id = Qry.Increment_Id inner join
		T0030_branch_master BM WITH (NOLOCK) ON  Q_I.Branch_Id = BM.Branch_ID Left join
		T0020_STATE_MASTER  SM WITH (NOLOCK) ON  SM.State_ID = BM.State_ID Inner join
		T0010_Company_Master CM WITH (NOLOCK) on  CM.Cmp_Id = EM.Cmp_ID inner join
		#Emp_Cons EC on EC.Emp_ID = EM.Emp_ID	
		WHERE    EM.Cmp_ID = @Cmp_ID
			
			
		

