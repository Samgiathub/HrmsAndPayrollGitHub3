
--SP_EMP_RECORD_GET_RETAINING 120,'01-jan-2021','01-Apr-2022'
  ---24/01/2022 (CREATED  BY DEEPALI )
  CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_RETAINING] 
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = ''  
 ,@Emp_Search int= 0	
 ,@RetainStatus int = 0
 
 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON  
   
   
   
Begin
  --if Not exists(select * from T0090_Retaining_Lock_Setting WITH (NOLOCK) where  @From_Date between from_Date and To_Date )  -- from_date >= @From_Date and To_Date <= @From_Date)  --
  --Begin
		--Raiserror('Retaining Period Not Exist. Please Select Different Effective Date  !!!',16,2)						
		--return -1
  --end

 if @Branch_ID = 0  
  set @Branch_ID = null  
 if @Cat_ID = 0  
  set @Cat_ID = null  
     
 if @Type_ID = 0  
  set @Type_ID = null  
 if @Dept_ID = 0  
  set @Dept_ID = null  
 if @Grd_ID = 0  
  set @Grd_ID = null  
 if @Emp_ID = 0  
  set @Emp_ID = null  
    
 If @Desig_ID = 0  
  set @Desig_ID = null    
   
   
 Declare @Emp_Cons Table  
 (  
	  Emp_ID numeric , 
	 Branch_ID numeric
 )  
   
 --if @Constraint <> ''  
 begin  

  CREATE TABLE #Emp_Cons 
			(      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric,
				--For_date datetime,
				--Employee_Code Varchar(250),      
				--Employee_Name Varchar(500),
				--Dept_Name VARCHAR(500),
				--Desig_Name VARCHAR(500)    
			);
				
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@From_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,0,0,0,0,0,0,0,'0',0,1             
					
   
	END
	If(@RetainStatus=4)
	begin 
		
		select distinct em.Emp_ID, em.Emp_Full_Name as'Emp_F_Name',em.Alpha_Emp_Code,EM.Branch_ID,EM.Desig_Id
		, em.Alpha_Emp_Code + ' : ' + em.Emp_Full_Name as 'EMP_FULL_NAME'  
		from T0100_EMP_RETAINTION_STATUS RO
		 inner join T0210_Retaining_Payment_Detail rd  WITH (NOLOCK) on rd.Emp_ID=RO.Emp_Id and rd.Cmp_ID = @Cmp_ID
		inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=RO.Emp_Id and em.Cmp_ID = @Cmp_ID
		--where [Start_Date] >= @From_Date and [END_date] <= @To_Date	
	
	End
	If(@RetainStatus=2)
	begin 
		
		select distinct em.Emp_ID, em.Emp_Full_Name as'Emp_F_Name',em.Alpha_Emp_Code,EM.Branch_ID,EM.Desig_Id
		, em.Alpha_Emp_Code + ' : ' + em.Emp_Full_Name as 'EMP_FULL_NAME'  
		from T0100_EMP_RETAINTION_STATUS RO
		inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=RO.Emp_Id and em.Cmp_ID = @Cmp_ID
		--where [Start_Date] >= @From_Date and [END_date] <= @To_Date
	End
	else 
	begin
		if @RetainStatus=1 --for fetch records not assigned Retaining Status
			BEGIN				
		
				select distinct em.Emp_ID,vi.Emp_Full_Name as'Emp_F_Name',vi.Branch_ID,vi.Branch_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,Format(@From_Date,'dd/MM/yyyy') As 'Start_Date', 
				em.Alpha_Emp_Code + ' : ' + vi.Emp_Full_Name as 'EMP_FULL_NAME'				
				from T0080_EMP_MASTER em 
				inner join V0095_Increment_All_Data vi on em.Increment_ID = vi.Increment_ID 		
				and vi.Emp_ID  not in (SELECT distinct Emp_ID  FROM T0100_EMP_RETAINTION_STATUS RO WHERE RO.Emp_ID=em.Emp_ID  AND RO.is_Retain_ON= 1) and Vi.Cmp_ID =@Cmp_ID
				--where  vi.Date_Of_Join  >= cast(@From_Date as Date) 
				
				--WHERE   NOT EXISTS(SELECT 1 FROM T0100_EMP_RETAINTION_STATUS RO WHERE ES.Emp_ID=RO.Emp_ID  AND RO.is_Retain_ON= 1)
				--CONVERT(CHAR(10),vi.Date_Of_Join,120)  as joining , CONVERT(CHAR(10),@From_Date_Temp,120) as st_date ,
				--datediff(d, CONVERT(CHAR(10),@From_Date_Temp,120),CONVERT(CHAR(10),vi.Date_Of_Join,120)) as days	
 
			END
		else   -- to fetch records already assigned Retaining status =1
			
			BEGIN	
				
				if @RetainStatus=2
				begin 
				select distinct es.Emp_ID, vi.Emp_Full_Name as'Emp_F_Name',vi.Branch_ID,vi.Branch_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,
				Format(RO.start_Date,'dd/MM/yyyy') as'Start_Date' , em.Alpha_Emp_Code + ' : ' + vi.Emp_Full_Name as 'EMP_FULL_NAME'  from #Emp_Cons es
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				inner Join T0100_EMP_RETAINTION_STATUS RO ON RO.Emp_Id = em.Emp_Id
				--WHERE EXISTS(SELECT 1 FROM T0100_EMP_RETAINTION_STATUS RO WHERE ES.Emp_ID=RO.Emp_ID AND RO.is_Retain_ON= 1)
				--Where charindex(';' + cast(@FROM_DATE as varchar(11)),hw.WeekOffDate)>0
				end
			Else
			BEGIN	
				
				select distinct es.Emp_ID, vi.Emp_Full_Name as'Emp_F_Name',vi.Branch_ID,vi.Branch_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,
				Format(RO.start_Date,'dd/MM/yyyy') as'Start_Date' , em.Alpha_Emp_Code + ' : ' + vi.Emp_Full_Name as 'EMP_FULL_NAME'  from #Emp_Cons es
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				inner Join T0100_EMP_RETAINTION_STATUS RO ON RO.Emp_Id = em.Emp_Id
			
			END
			end
		end	

	END 
	


