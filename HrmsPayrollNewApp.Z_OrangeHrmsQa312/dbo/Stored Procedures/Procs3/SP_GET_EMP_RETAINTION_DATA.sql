-- =============================================
-- Author:		Deepali Mhaske
-- Create date: 20-12-2021
-- Description:	GET_EMP_RETAINTION_DATA 
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_EMP_RETAINTION_DATA]
  @Cmp_ID    numeric        
 ,@Start_Date   datetime        
 --,@To_Date    datetime
 ,@Emp_ID    numeric  = 0       
 ,@constraint   varchar(MAX)  =''
 ,@Retain_Type numeric= 0
 ,@Branch_ID			VARCHAR(MAX) = ''
 ,@Grd_ID			VARCHAR(MAX) = ''
 ,@Cat_ID			VARCHAR(MAX) = ''	
 ,@Dept_ID			VARCHAR(MAX) = ''
 ,@Desig_ID			VARCHAR(MAX) = ''	
 ,@Vertical_ID		VARCHAR(MAX) = ''
 ,@SubVertical_ID	VARCHAR(MAX) = ''
 ,@Type_ID			numeric  = 0
 ,@Segment_Id VARCHAR(MAX) = ''	
 ,@SubBranch_ID	VARCHAR(MAX) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @Required_Execution BIT;
	DECLARE @Return_Record_set numeric = 1 
	
	BEGIN
	if Not exists(select * from T0090_Retaining_Lock_Setting WITH (NOLOCK) where  @Start_Date between from_Date and To_Date  AND Cmp_ID=@Cmp_ID)  -- from_date >= @From_Date and To_Date <= @From_Date)  --
	Begin
		Raiserror('Retaining Period Does Not Exist. Please Select Different Effective Date!',16,2)						
		return -1
	end
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
				
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@Start_Date,@Start_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,'',0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               
					
   	SET @Required_Execution  =1;		
	END
		if @Retain_Type=1 --for fetch records not assigned Retaining Status
			BEGIN			
				select distinct es.Emp_ID,vi.Emp_Full_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,Format(@Start_Date,'dd/MM/yyyy')    As 'Start_Date' from #Emp_Cons es
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				WHERE NOT EXISTS(SELECT 1 FROM T0100_EMP_RETAINTION_STATUS RO WHERE ES.Emp_ID=RO.Emp_ID  AND RO.is_Retain_ON= 1)
			END
		else   -- to fetch records already assigned Retaining status =1
			BEGIN	
				
				select distinct es.Emp_ID, vi.Emp_Full_Name,vi.Dept_Name,vi.Desig_Name,em.Alpha_Emp_Code,Format(RO.start_Date,'dd/MM/yyyy') as'Start_Date'   from #Emp_Cons es
				inner join V0095_Increment_All_Data vi on es.Increment_ID=vi.Increment_ID
				inner join T0080_EMP_MASTER em WITH (NOLOCK) on em.Emp_ID=es.Emp_ID
				inner Join T0100_EMP_RETAINTION_STATUS RO ON RO.Emp_Id = em.Emp_Id AND RO.is_Retain_ON= 1
				WHERE EXISTS(SELECT 1 FROM T0100_EMP_RETAINTION_STATUS RO WHERE ES.Emp_ID=RO.Emp_ID AND RO.is_Retain_ON= 1)
				--Where charindex(';' + cast(@FROM_DATE as varchar(11)),hw.WeekOffDate)>0
			END
			
		--Insert Into #Data(Emp_Id,For_date,Employee_Code,Employee_Name)
		--values()
	END 



