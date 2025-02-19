-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[AX_JV_REPORT_WESTROCK_SALARY_Old]
	 @Cmp_Id	numeric output	 
	 ,@From_Date  datetime
	 ,@To_Date  datetime
	 ,@Flag Char = 'C'
	 ,@AD_id_Pass Numeric = 0
	 ,@Cost_Center	varchar(MAX) =''    
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Month numeric(18,0)
	Declare @Year numeric(18,0)

	set @Month = Month(@To_Date)
	set @Year = Year(@To_Date)

    CREATE table #Temp_report_Label
		(
			Row_ID  numeric(18, 0) NOt null,
			Label_Name  varchar(200) not null,
			Cost_id varchar(10)
			
		)
			
	CREATE table #Temp_Salary_JV_Report		
		(
			Row_id numeric(18, 0) Null,		
			AD_ID numeric(18,0) Null,			
			Label_Name varchar(200) Null,
			Label_Value varchar(max) null,	
			Cost_Flag varchar(10),
			Segment_ID numeric(18,0) default 0,
			Segment_Name varchar(max) null,
			Center_ID numeric(18,0) default 0,
			Center_Name varchar(max)
			
		)
	

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				VALUES     (3,'GL Code_1','C1')

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				VALUES     (4,'Employee Classification_1','C1')

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				--VALUES     (5,'Non-Production_SG&A_1')
				select 5,Center_Name,'C1' from T0040_COST_CENTER_MASTER WITH (NOLOCK) where Center_ID=55

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				VALUES     (6,'GL Code_2','C2')

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				VALUES     (7,'Employee Classification_2','C2')

				INSERT INTO #Temp_report_Label (Row_ID, Label_Name,Cost_id)
				--VALUES     (8,'Production_COGS_2')
				select 8,Center_Name,'C2' from T0040_COST_CENTER_MASTER WITH (NOLOCK) where Center_ID=56
	
				
				INSERT INTO #Temp_Salary_JV_Report(Row_id,Ad_id,Label_Name,Cost_Flag,Segment_ID,Segment_Name,Center_ID,Center_Name)
				select Row_ID,A.Ad_id,Label_Name,Cost_id,B.Segment_ID,Segment_Name,A.Center_ID,Center_Name
				from #Temp_report_Label cross join									
					 T0040_Business_Segment B WITH (NOLOCK) cross join
					 T0040_COST_CENTER_MASTER C WITH (NOLOCK) inner join
					 T9999_Ax_Mapping A WITH (NOLOCK) on A.Center_ID = c.Center_ID
				where B.Segment_ID in (112,113) --and A.Center_ID in (55,56)

				select * from #Temp_Salary_JV_Report
				return

				update #Temp_Salary_JV_Report
				set Center_ID=ac.Center_ID
				from #Temp_Salary_JV_Report TJ inner join   
					 V0080_EMP_MASTER_INCREMENT_GET E on Tj.Segment_ID = E.Segment_ID inner join 
					 T0210_MONTHLY_AD_DETAIL MS on E.Emp_ID=MS.Emp_ID inner join
					 T0050_AD_MASTER A on A.AD_ID = MS.AD_ID inner join
					 T9999_Ax_Mapping AM on A.AD_ID = AM.Ad_id inner join
					 T0040_COST_CENTER_MASTER C on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID  inner join
					 T0040_Business_Segment B on b.Segment_ID = e.Segment_ID inner join
					 (
						select c.Center_ID,c.Center_Name,t.Cost_Flag from
						T0040_COST_CENTER_MASTER C WITH (NOLOCK) inner join #Temp_Salary_JV_Report T on C.Center_Name = T.Label_Name
						where t.Cost_Flag='C1'
					 ) ac on ac.Center_ID = am.Center_ID
				where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020 --and  Cost_Flag='C1'  and Row_id <= 5
					  
				update #Temp_Salary_JV_Report
				set	Label_Value=am.Account
				from #Temp_Salary_JV_Report TJ inner join   
					 V0080_EMP_MASTER_INCREMENT_GET E on Tj.Segment_ID = E.Segment_ID inner join 
					 T0210_MONTHLY_AD_DETAIL MS on E.Emp_ID=MS.Emp_ID inner join
					 T0050_AD_MASTER A on A.AD_ID = MS.AD_ID inner join
					 T9999_Ax_Mapping AM on A.AD_ID = AM.Ad_id inner join
					 T0040_COST_CENTER_MASTER C on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID inner join
					 T0040_Business_Segment B on b.Segment_ID = e.Segment_ID
				where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020 and  Label_Name='GL Code_1'
				
				select * from #Temp_Salary_JV_Report 
				order by Center_Name
				return
				
				update #Temp_Salary_JV_Report
				set Label_Value=AM.Narration
				from #Temp_Salary_JV_Report TJ inner join   
					 V0080_EMP_MASTER_INCREMENT_GET E on Tj.Segment_ID = E.Segment_ID inner join 
					 T0210_MONTHLY_AD_DETAIL MS on E.Emp_ID=MS.Emp_ID inner join
					 T0050_AD_MASTER A on A.AD_ID = MS.AD_ID inner join
					 T9999_Ax_Mapping AM on A.AD_ID = AM.Ad_id inner join
					 T0040_COST_CENTER_MASTER C on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID inner join
					 T0040_Business_Segment B on b.Segment_ID = e.Segment_ID
				where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020 and  Label_Name='Employee Classification_1'

				--update #Temp_Salary_JV_Report
				--set Label_Value=sum(M_AD_Amount)
				--from #Temp_Salary_JV_Report TJ inner join   
				--	 V0080_EMP_MASTER_INCREMENT_GET E on Tj.Segment_ID = E.Segment_ID inner join 
				--	 T0210_MONTHLY_AD_DETAIL MS on E.Emp_ID=MS.Emp_ID inner join
				--	 T0050_AD_MASTER A on A.AD_ID = MS.AD_ID inner join
				--	 T9999_Ax_Mapping AM on A.AD_ID = AM.Ad_id inner join
				--	 T0040_COST_CENTER_MASTER C on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID inner join
				--	 T0040_Business_Segment B on b.Segment_ID = e.Segment_ID
				--where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020 and  Label_Name='Non-Production_SG&A_1'
				--group by Ad_id

				select * from #Temp_Salary_JV_Report
				
				DECLARE @SQL VARCHAR(MAX)
				DECLARE @COLS VARCHAR(MAX)
				DECLARE @SQL1 VARCHAR(MAX)

				SELECT	 @COLS = COALESCE(@COLS + ',','')  + '[' + Label_Name + '\' + Segment_Name  + ']' 
					FROM	(
								SELECT	Row_Number() Over(PARTITION By Segment_ID order by Segment_ID) as Row_Id,Label_Name,Segment_Name										
								FROM	#Temp_Salary_JV_Report											
							) PL
					GROUP BY Label_Name,Segment_Name
					ORDER BY MAX(ROW_ID)	
				select @COLS

				DECLARE @CastCols Varchar(Max)
					Select @CastCols = IsNull(@CastCols +',', '') + '''="''+ (CONVERT(varchar, CAST('+ Data + ' AS money), 1) + ''"'') as ' + Data
					FROM	dbo.Split(@COLS, ',')
				
				select @CastCols
				--(Dr_Cr,Payout_Provision,Label_Name,Label_Value,Row_id)
				
				Select Case When AD_FLAG = 'I' then 'Dr' Else 'Cr' END As Dr_Cr,
					   Case When A.AD_NOT_EFFECT_SALARY=1 then 'Payout' Else 'Provision' END As Payout_Provision,Am.Account,AM.Narration
					   ,(M_Ad_Amount),AM.ad_id,Alpha_Emp_Code,Emp_Full_Name,AM.Center_ID
					   
				from 
					 V0080_EMP_MASTER_INCREMENT_GET E inner join 
					 T0210_MONTHLY_AD_DETAIL MS WITH (NOLOCK) on E.Emp_ID=MS.Emp_ID inner join
					 T0050_AD_MASTER A WITH (NOLOCK) on A.AD_ID = MS.AD_ID inner join
					 T9999_Ax_Mapping AM WITH (NOLOCK) on A.AD_ID = AM.Ad_id inner join
					 T0040_COST_CENTER_MASTER C WITH (NOLOCK) on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID inner join
					 T0040_Business_Segment B WITH (NOLOCK) on b.Segment_ID = e.Segment_ID
				where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020


				
				Select Case When AD_FLAG = 'I' then 'Dr' Else 'Cr' END As Dr_Cr,
					   Case When A.AD_NOT_EFFECT_SALARY=1 then 'Payout' Else 'Provision' END As Payout_Provision,Am.Account,AM.Narration
					   ,sum(M_Ad_Amount),AM.ad_id
					   
				from 
					 V0080_EMP_MASTER_INCREMENT_GET E inner join 
					 T0210_MONTHLY_AD_DETAIL MS WITH (NOLOCK) on E.Emp_ID=MS.Emp_ID inner join
					 T0050_AD_MASTER A WITH (NOLOCK) on A.AD_ID = MS.AD_ID inner join
					 T9999_Ax_Mapping AM WITH (NOLOCK) on A.AD_ID = AM.Ad_id inner join
					 T0040_COST_CENTER_MASTER C WITH (NOLOCK) on c.Center_ID = am.Center_ID and e.Center_ID=c.Center_ID inner join
					 T0040_Business_Segment B WITH (NOLOCK) on b.Segment_ID = e.Segment_ID
				where Month(MS.To_date) = 6  AND Year(MS.To_date) = 2020
				group by Am.Account, AM.AD_ID,AD_FLAG,AD_NOT_EFFECT_SALARY,AM.Narration
				
				
				--Select * from #Temp_Salary_JV_Report


END
