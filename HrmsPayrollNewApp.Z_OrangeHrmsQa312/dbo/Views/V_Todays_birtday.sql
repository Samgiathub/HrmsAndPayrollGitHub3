




CREATE VIEW [dbo].[V_Todays_birtday]
AS
Select (CAST(Emp_Code AS varchar(20))+ '-' + Initial + ' ' + Emp_First_Name + ' ' + Emp_Last_Name) as emp_full_name ,CONVERT(VARCHAR(11),Date_Of_birth , 106) as Date_Of_Birth,E.Branch_ID,BM.Branch_Name
,Work_Email  ,E.Cmp_id	
from T0080_Emp_master E WITH (NOLOCK)
inner join (
			Select Branch_ID,I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
				(
				select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)    
				where Increment_Effective_date <= Getdate()  group by emp_ID
				) Qry on    
				I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date
			) qry2 on qry2.Emp_ID=e.Emp_ID
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) On qry2.Branch_ID = BM.Branch_ID 
			where E.Emp_ID in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) ) 
	         and Month(Date_Of_Birth)=Month(Getdate()) And day(Date_Of_Birth)=day(Getdate())-- >=@From_Date and Date_Of_Birth <=@To_Date



