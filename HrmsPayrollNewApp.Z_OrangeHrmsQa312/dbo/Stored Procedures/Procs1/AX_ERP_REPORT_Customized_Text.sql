

-- Created by rohit for Customized report of Ax on 12022016
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_ERP_REPORT_Customized_Text]
	  @Cmp_Id	numeric output	 
	 ,@From_Date  datetime
	 ,@To_Date  datetime
	 ,@Branch_ID		varchar(MAX)  =''    --Added by Jaina 05-04-2018 Start      
	 ,@Cat_ID			varchar(MAX) = ''           
	 ,@Grd_ID			varchar(MAX) =''       
	 ,@Type_ID			varchar(MAX) =''                
	 ,@Dept_ID			varchar(MAX) =''                  
	 ,@Desig_ID			varchar(MAX) =''     --Added by Jaina 05-04-2018 End 
	 ,@Cost_Center		varchar(MAX) =''     --Added by Ramiz 22/05/2018
	 ,@Format			varchar(5) = ''		 --Added by Ramiz 22/05/2018
	 ,@Business_Segment varchar(MAX) = ''    --Added by Jaina 25-08-2020
AS
begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @i int = 1
DECLARE @j int = 1
DECLARE @datano int = 1
Declare @str1 nvarchar(200) =''
Declare @str2 nvarchar(50) =''
declare @Head_name nvarchar(50)
declare @Ad_ID int = 0
declare @sorting_no int = 0
declare @SegmentID int = 0

Create table #result
(
	Data nvarchar(max)
)


insert into #result select top 1 concat('G''MISC,,101,GEN,',convert(varchar,Month_End_Date,112),',,INR,STDCO,1,,',convert(varchar,Month_End_Date,112),',',convert(varchar,Month_End_Date,112),',',convert(varchar,Month_End_Date,112),','
,convert(varchar,Month_End_Date,112),',','Manual Salary JV
') from T0200_Monthly_Salary where Cmp_ID=@Cmp_ID and Month_St_Date = @From_Date and Month_End_Date = @To_Date

IF (select  COUNT(1) from #result) = 0
BEGIN
return
END

select  ROW_NUMBER() OVER (ORDER BY min(Sorting_no)  asc) AS rownumber,Head_Name,Ad_id,min(Sorting_no)as Sorting_no  into #temp from T9999_Ax_Mapping where Cmp_Id=@Cmp_ID group by Head_Name,Ad_id ORDER BY min(Sorting_no) 

WHILE @i <= (Select COUNT(1)  From #temp)
BEGIN
--- Profetional tax
select @Ad_ID = Ad_id, @sorting_no = Sorting_no, @Head_name = Head_Name from #temp where rownumber = @i    
	IF (select Ad_id From #temp where  Ad_id = @Ad_ID and Sorting_no= @sorting_no) = '1001' 
	BEGIN
		   select  ROW_NUMBER() OVER (ORDER BY (Sorting_no)  asc) AS rownumber,Head_Name,Ad_id,(Sorting_no)as Sorting_no,(Segment_ID) as Segment_ID  into #temp_PT from T9999_Ax_Mapping where Cmp_Id=@Cmp_ID and Ad_id=1001 ORDER BY (Sorting_no) 
			
		WHILE @j <= (select COUNT(1)  from T9999_Ax_Mapping where Cmp_id=@Cmp_ID and Ad_id=@Ad_ID and Head_Name=@Head_name)
		BEGIN
			select @Ad_ID = Ad_id, @sorting_no = Sorting_no, @Head_name = Head_Name , @SegmentID = Segment_ID  from #temp_PT where rownumber = @j 
			 
			 insert into #result   Select CONCAT('D',',',@datano,',',@datano,',',@datano,',',D.Account,',',',',',',D.Narration,',',
											-1,',',',',
										(
											SELECT SUM(PT_Amount) FROM T0200_MONTHLY_SALARY A
											LEFT JOIN T0095_INCREMENT B ON A.Cmp_ID= B.Cmp_ID and A.Increment_ID= B.Increment_ID
											LEFT JOIN T9999_Ax_Mapping E ON E.Cmp_id= B.Cmp_ID and E.Segment_ID= B.Segment_ID 
											LEFT JOIN T0040_Business_Segment BSC ON B.Segment_ID= BSC.Segment_ID and BSC.Cmp_ID = B.Cmp_ID
											where BSC.Cmp_ID = @Cmp_ID and A.Cmp_ID=@Cmp_ID and B.Cmp_ID=@Cmp_ID and A.Month_St_Date=@From_Date and A.Month_End_Date=@To_Date and Sorting_no =@sorting_no 
											and E.Segment_ID = @SegmentID   
										),',INR'
				) as Cost_Center_first
				From T9999_Ax_Mapping D
				where D.Cmp_ID = @Cmp_ID  and D.Ad_id=@Ad_ID and D.Sorting_no = @sorting_no and D.Segment_ID=@SegmentID
				
				set @datano = @datano + 1
			set @j  = @j + 1	

		END
	END
	ELSE
	BEGIN
	--Basic Salary
	set @str1 =	(Select TOP 1 CONCAT('D',',',@datano,',',@datano,',',@datano,',',A.Account,',',',',',',A.Narration,',',
						CASE 
						WHEN A.Ad_id = '2003' THEN '1'
						ELSE (select TOP 1 CASE 
										WHEN B.AD_FLAG = 'I' THEN '1' 
										WHEN B.AD_FLAG = 'D' THEN '-1'
										END  From T9999_Ax_Mapping A
								LEFT JOIN T0050_AD_MASTER B on A.Ad_id= B.AD_ID
								Where A.Cmp_ID=@Cmp_ID and A.Ad_id = @Ad_ID and A.Sorting_no= @sorting_no
							 )
						END,
						',',','
						)
				From T9999_Ax_Mapping A
				LEFT JOIN T0050_AD_MASTER B on A.Ad_id= B.AD_ID
				Where A.Cmp_ID=@Cmp_ID	and A.Ad_id = @Ad_ID and A.Sorting_no= @sorting_no
				)
	set @str2 =	(select CAST((select TOP 1
		case 
		WHEN A.Ad_id = '2003' THEN (select SUM(Salary_Amount) from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID and Month_St_Date=@From_Date and Month_End_Date=@To_Date)
		WHEN A.Ad_id = '1001' THEN (select SUM(PT_Amount) from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID and Month_St_Date=@From_Date and Month_End_Date=@To_Date)
		WHEN A.Ad_id = '1003' THEN (select SUM(Net_Amount) from T0200_MONTHLY_SALARY where Cmp_ID = @Cmp_ID and Month_St_Date=@From_Date and Month_End_Date=@To_Date)
		ELSE (select sum(A.M_AD_Amount)
				from T0210_MONTHLY_AD_DETAIL A
				Where A.Cmp_ID=@Cmp_ID	and A.AD_ID= @Ad_ID
			)
		END Ammount
		from T9999_Ax_Mapping A
				LEFT JOIN T0050_AD_MASTER B on A.Ad_id= B.AD_ID
				Where A.Cmp_ID=@Cmp_ID	and A.Ad_id =  @Ad_ID and A.Sorting_no= @sorting_no
		) AS varchar))

		insert into #result select CONCAT(@str1,@str2,',','INR') as Cost_Center_last
		
	END


--///////////////////// Detailed Cost Center //////////////////////////

IF (select COUNT(1) from T9999_Ax_Mapping where Cmp_id=@Cmp_ID and Head_Name = @Head_name and Center_ID != 0 and Ad_id !=1001) > 1
BEGIN
declare @str as nvarchar(200) = ''

	insert into #result Select  CAST(concat('A',',',@datano,',','DPT',',',CCM.Center_Code,',',',',',',',','0',',',
									CASE WHEN AX.Ad_id= '2003' THEN
									CAST(MS.Salary_Amount as varchar)
									ELSE
									CAST(MAD.M_AD_Amount as varchar)
									END)
							as nvarchar(200)
							)
From T0095_INCREMENT I
LEFT JOIN T0200_MONTHLY_SALARY MS ON I.Cmp_ID = MS.Cmp_ID and I.Emp_ID = MS.Emp_ID
 --LEFT JOIN T0080_EMP_MASTER Emp ON I.cmp_ID = Emp.Cmp_ID and I.Emp_id = Emp.Emp_ID
 LEFT JOIN T0040_COST_CENTER_MASTER CCM ON CCM.Cmp_ID= I.Cmp_ID and CCM.Center_ID = I.Center_ID
 LEFT JOIN T9999_Ax_Mapping AX ON I.Center_ID= AX.Center_ID
LEFT JOIN T0210_MONTHLY_AD_DETAIL MAD ON MAD.Cmp_ID = I.Cmp_ID and MAD.Emp_ID = I.Emp_ID and  MAD.AD_ID= AX.Ad_id
Where I.Cmp_ID=@Cmp_ID and AX.Head_Name= @Head_name and MS.Month_St_Date = @From_Date and MS.Month_End_Date = @To_Date 
--set @str = 
--select @str = SUBSTRING(@str,1,(LEN(@str)-1)) 
--select @str as Detailed_Cost_Center
END
set @datano = @datano + 1
SET @i = @i + 1 
    /* do some work */
END
select * from #result
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp;   
IF OBJECT_ID('tempdb..#temp_PT') IS NOT NULL DROP TABLE #temp_PT;
IF OBJECT_ID('tempdb..#result') IS NOT NULL DROP TABLE #result;
	
END
	
