


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_EMPLOYEE_GRADEALLOW_DETAIL_APP]  
 @Cmp_ID int,  
 @Emp_Tran_ID bigint,
 @Approved_Date DateTime,
 @Grd_ID int  =0,
 @Show_Hidden_Allowance bit=0   

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Last_Increment table  
(  
Approved_Date datetime,  
Increment_ID int,  
Cmp_ID int,  
Emp_Tran_ID bigint,  
Grd_ID int,
Branch_Id int 
) 

Insert into @Last_Increment  
	select I.Increment_Effective_Date,I.Increment_ID,I.Cmp_ID,I.Emp_Tran_ID,I.Grd_ID,I.Branch_ID  
	From T0070_EMP_INCREMENT_APP I WITH (NOLOCK) inner join     
	   (
			select max(Increment_effective_Date) as Approved_Date,Emp_Tran_ID  
			from T0070_EMP_INCREMENT_APP WITH (NOLOCK)   
			where Increment_Effective_date <= @Approved_Date and Cmp_ID = @Cmp_ID 
			group by Emp_Tran_ID 
		) Qry 
	on I.Emp_Tran_ID  = Qry.Emp_Tran_ID  and I.Increment_effective_Date = Qry.Approved_Date 
	Where I.Emp_Tran_ID  = @Emp_Tran_ID 


			if @Grd_ID  = 0
			 Begin

			 SELECT 
				  Am.Ad_id,Am.Ad_Flag as Ad_Flag,
				  GA.Ad_Mode as AD_MODE,
				  AM.AD_NAME as AD_NAME,
				  Ga.AD_ID as AD_ID,
				  GA.Ad_Max_Limit as Ad_Max_Limit,
				  --dbo.F_Show_Decimal(isnull(GA.Ad_Amount,0),ga.cmp_id) as AD_AMOUNT ,
				  (CASE WHEN Isnull(GBA.AD_Amount,0) <> 0 then dbo.F_Show_Decimal(isnull(GBA.Ad_Amount,0),Ga.cmp_id) Else dbo.F_Show_Decimal(isnull(GA.Ad_Amount,0),Ga.cmp_id) End) As AD_AMOUNT,
				  dbo.F_Show_Decimal(isnull(GA.Ad_Percentage,0),GA.cmp_id) as AD_PERCENTAGE,
				  0 as Ad_tran_id,  
				  D.Emp_Tran_ID,D.Approved_Date as Date,D.Increment_ID,E.Emp_Code ,E.Alpha_Emp_Code, E.Emp_Full_Name , Inc.Branch_ID
				
			  FROM  @Last_Increment D 	
					  inner join T0070_EMP_INCREMENT_APP Inc WITH (NOLOCK) on inc.Increment_ID = D.Increment_ID  	 
					  inner join T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK) on GA.Grd_ID = D.Grd_ID  
					  inner join t0050_ad_master AM WITH (NOLOCK) on AM.AD_ID=GA.Ad_ID and  AM.CMP_ID=GA.cmp_id
					  inner join T0060_EMP_MASTER_APP E  WITH (NOLOCK) on D.Emp_Tran_ID =E.Emp_Tran_ID    
					  left OUTER JOIN T0100_AD_Grade_Branch_Wise GBA WITH (NOLOCK) ON GBA.AD_ID = GA.Ad_ID and GBA.Grd_ID = GA.Grd_ID and GBA.Cmp_ID = GA.cmp_id and GBA.Branch_ID = D.Branch_ID
					  where isnull(Am.is_optional,0) = 0
					   and (CASE WHEN @Show_Hidden_Allowance = 0  and  AM.AD_NOT_EFFECT_SALARY = 1 and AM.Hide_In_Reports = 1 THEN 0 else 1 END )=1  --Change By Jaina 23-12-2016
					   order BY AM.AD_LEVEL asc
				--where GA.AD_MODE is not  null	 and (GA.AD_PERCENTAGE is not NULL or GA.AD_AMOUNT is NOT NULL)
				End
			Else
				BEGIN
					 Declare @Branch_ID Numeric(18,0)
					 Select @Branch_ID = Branch_Id From @Last_Increment Where Emp_Tran_ID  = @Emp_Tran_ID  and Cmp_ID = @Cmp_ID
						
					 SELECT 
						  Am.Ad_id,Am.Ad_Flag as Ad_Flag,
						  GA.Ad_Mode as AD_MODE,
						  AM.AD_NAME as AD_NAME,
						  Ga.AD_ID as AD_ID,
						  GA.Ad_Max_Limit as Ad_Max_Limit,
						  --dbo.F_Show_Decimal(isnull(GA.Ad_Amount,0),Ga.cmp_id) as AD_AMOUNT ,
						  (CASE WHEN Isnull(qry_1.AD_Amount,0) <> 0 AND qry_1.AD_CALCULATE_ON = '0' THEN dbo.F_Show_Decimal(isnull(qry_1.Ad_Amount,0),Ga.cmp_id) 
								WHEN Isnull(qry_1.AD_Amount,0) <> 0 AND qry_1.AD_CALCULATE_ON <> '0' THEN '0'
								Else dbo.F_Show_Decimal(isnull(GA.Ad_Amount,0),Ga.cmp_id) 
						   End) As AD_AMOUNT,
						  (CASE WHEN  Isnull(qry_1.AD_Amount,0) <> 0 AND Isnull(qry_1.AD_CALCULATE_ON,'0') <> '0' THEN dbo.F_Show_Decimal(isnull(qry_1.Ad_Amount,0),ga.cmp_id) 
								ELSE dbo.F_Show_Decimal(isnull(GA.Ad_Percentage,0),ga.cmp_id)
						  END) as AD_PERCENTAGE,
						  --dbo.F_Show_Decimal(isnull(GA.Ad_Percentage,0),ga.cmp_id) as AD_PERCENTAGE,
						  0 as Ad_tran_id
					 FROM  	 
						  T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK) 
						  inner join t0050_ad_master AM WITH (NOLOCK) on AM.AD_ID=GA.Ad_ID and  AM.CMP_ID=GA.cmp_id
						  Left OUTER JOIN (SELECT GBA.AD_ID,GBA.Grd_ID,GBA.AD_Amount,GBA.AD_CALCULATE_ON 
										   From T0100_AD_Grade_Branch_Wise GBA WITH (NOLOCK)
										   INNER JOIN(
														Select MAX(Effective_Date) As EffectiveDate,AD_ID,Grd_ID,Branch_ID 
														From T0100_AD_Grade_Branch_Wise WITH (NOLOCK)
														Where Cmp_ID = @Cmp_ID AND Branch_ID = @Branch_ID
														GROUP By AD_ID,Grd_ID,Branch_ID
											          ) as qry 
											ON GBA.Effective_Date = qry.EffectiveDate AND GBA.Ad_ID = qry.AD_ID and GBA.Branch_ID = qry.Branch_ID AND GBA.Grd_ID = qry.Grd_ID
										   ) as qry_1 
						  ON GA.Grd_ID = qry_1.Grd_ID AND GA.Ad_ID = qry_1.AD_ID
						  --left OUTER JOIN T0100_AD_Grade_Branch_Wise GBA 
								--ON GBA.AD_ID = GA.Ad_ID and GBA.Grd_ID = GA.Grd_ID and GBA.Cmp_ID = GA.cmp_id and GBA.Branch_ID = @Branch_ID
								--INNER JOIN(
								--	Select MAX(Effective_Date) as EffectiveDate,Branch_ID,Grd_ID,Ad_ID From T0100_AD_Grade_Branch_Wise
								--	Where Cmp_ID = @Cmp_ID
								--	GROUP BY Branch_ID,Grd_ID,Ad_ID
								--) as qry ON GBA.Effective_Date = qry.EffectiveDate AND GBA.Branch_ID = qry.Branch_ID and GBA.Grd_ID = qry.Grd_ID and GBA.AD_ID = qry.AD_ID
						  where  GA.Grd_ID =@Grd_ID and  isnull(Am.is_optional,0) = 0 
						  and (CASE WHEN @Show_Hidden_Allowance = 0  and  AM.AD_NOT_EFFECT_SALARY = 1 and AM.Hide_In_Reports = 1 THEN 0 else 1 END )=1  --Change By Jaina 23-12-2016
						  order BY AM.AD_LEVEL asc
					
				 end	

REturn		 



