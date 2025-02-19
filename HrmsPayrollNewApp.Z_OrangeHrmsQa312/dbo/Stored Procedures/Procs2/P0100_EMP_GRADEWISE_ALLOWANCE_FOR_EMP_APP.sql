
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_GRADEWISE_ALLOWANCE_FOR_EMP_APP]   
	@Cmp_ID int,  
	@Grd_Id int,  
	@Join_Date datetime =Null,  
	@Increment_ID int,
	@Branch_ID int = 0,
	@Emp_Tran_ID bigint =0 ,
	@Emp_Application_ID int =0 ,
	@Approved_Emp_ID int=0,
	@Approved_Date datetime = Null,
	@Rpt_Level int=0
	
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @All_Cons Table  
	(  
		Ad_ID numeric,
		Ad_Level numeric  
	)  
  
	insert into @All_Cons
		Select GA.Ad_ID,GA.Ad_Level from T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK)  inner join 
			T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = GA.Ad_ID
		where GA.Cmp_ID = @Cmp_ID and GA.Grd_Id = @Grd_Id and isnull(AD.Is_Optional,0) <> 1 
		And Isnull(AD.AD_ACTIVE,0) = 1
		Order by Ad_Level  --Query change by Ripal 18Jun2014   
	
	--Select Ad_ID,Ad_Level from T0120_GRADEWISE_ALLOWANCE where Cmp_ID = @Cmp_ID and Grd_Id = @Grd_Id Order by Ad_Level 
	
	
	Declare @E_Ad_Flag varchar(1)  
	Declare @E_Ad_Mode varchar(5)  
	Declare @E_ad_perc numeric(22,5)  -- Changed by Gadriwala Muslim 19032015
	Declare @E_ad_Amount numeric(22,2)  
	Declare @E_ad_max_limit numeric(22,2)  
	Declare @Ad_Id_Temp as numeric(18,0)  
	Declare @AD_Calculate_on_Grade_Branch as Varchar(100)
	Set @AD_Calculate_on_Grade_Branch = ''

declare curAD cursor for            


select  Ad_ID from @All_Cons order by Ad_Level        

open curAD                        
  fetch next from curAD into @Ad_Id_Temp  
 while @@fetch_status = 0                      
  begin 
----ADD FOR GRADE SETTING---	   
   select @E_Ad_Flag=Ad_Flag,@E_Ad_Mode=GA.Ad_Mode,
   --@E_ad_perc=isnull(GA.ad_percentage,0),
   --@E_ad_Amount=isnull(GA.ad_Amount,0),
	@E_ad_Amount = (CASE WHEN Isnull(qry_1.AD_Amount,0) <> 0 AND qry_1.AD_CALCULATE_ON = '0' THEN 
							  isnull(qry_1.Ad_Amount,0)
						 WHEN Isnull(qry_1.AD_Amount,0) <> 0 AND qry_1.AD_CALCULATE_ON <> '0' THEN
							  0
						 Else 
							  isnull(GA.ad_Amount,0) 
					End),
	@E_ad_perc =   (CASE WHEN  Isnull(qry_1.AD_Amount,0) <> 0 AND Isnull(qry_1.AD_CALCULATE_ON,'0') <> '0' THEN 
							  isnull(qry_1.Ad_Amount,0) 
						  ELSE 
							  isnull(GA.Ad_Percentage,0)
					END),
   @E_ad_max_limit=isnull(GA.ad_max_limit,0),
   @AD_Calculate_on_Grade_Branch = ISNULL(qry_1.AD_CALCULATE_ON,'')
   from T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK) inner join T0050_AD_MASTER  AM WITH (NOLOCK) on GA.AD_ID = AM.Ad_ID 
		 LEFT OUTER JOIN
		(SELECT GBA.AD_ID,GBA.Grd_ID,GBA.AD_Amount,GBA.AD_CALCULATE_ON From T0100_AD_Grade_Branch_Wise GBA WITH (NOLOCK)
					INNER JOIN(
								Select MAX(Effective_Date) As EffectiveDate,AD_ID,Grd_ID,Branch_ID 
								From T0100_AD_Grade_Branch_Wise WITH (NOLOCK)
								Where Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID and Effective_Date <= @Join_Date
								GROUP By AD_ID,Grd_ID,Branch_ID
							  ) qry ON GBA.Effective_Date = qry.EffectiveDate 
								AND GBA.Ad_ID = qry.AD_ID and GBA.Branch_ID = qry.Branch_ID
								AND GBA.Grd_ID = qry.Grd_ID
			  ) as qry_1 
			  ON GA.Grd_ID = qry_1.Grd_ID AND GA.Ad_ID = qry_1.AD_ID 
   where GA.ad_id=@Ad_Id_Temp and GA.cmp_id=@cmp_id  AND GA.Grd_ID=@Grd_Id
   ----ADD FOR GRADE SETTING---	   
   
  --Select @Cmp_ID as Cmp_ID,@Emp_Tran_ID as Emp_Tran_ID,@Emp_Application_ID as Emp_Application_ID,@Ad_Id_Temp as Ad_Id_Temp,@Increment_ID as Increment_ID,@Join_Date as Join_Date,@E_Ad_Flag as E_Ad_Flag,@E_Ad_Mode as E_Ad_Mode,@E_ad_perc as E_ad_perc,@E_ad_Amount as  E_ad_Amount,@E_ad_max_limit as E_ad_max_limit,'I' as Type,@AD_Calculate_on_Grade_Branch as AD_Calculate_on_Grade_Branch,0,'' as IP_Address,@Approved_Emp_ID as Approved_Emp_ID,@Approved_Date as Approved_Date,@Rpt_Level  as  Rpt_Level
		exec P0075_EMP_EARN_DEDUCTION_APP 0,@Cmp_ID,@Emp_Tran_ID,@Emp_Application_ID,@Ad_Id_Temp,@Increment_ID,@Join_Date,@E_Ad_Flag,@E_Ad_Mode,@E_ad_perc,@E_ad_Amount,@E_ad_max_limit,'I',@AD_Calculate_on_Grade_Branch,0,'',@Approved_Emp_ID,@Approved_Date,@Rpt_Level 
	
	
   fetch next from curAD into @Ad_Id_Temp  
  end                      
 close curAD                      
 deallocate curAD  

RETURN


