CREATE PROCEDURE [dbo].[KPMS_P0100_FreqwiseTargetAchivement]                    
@rCmpId int,                          
@GoalSheet_Id int,                          
@goalAlt_id int,                  
@GS_Id int,                                
@rPermissionStr2 VARCHAR(MAX),            
@rType INT ,                      
@Emp_ID INT,                      
@Cmp_ID int,                      
@User_ID Int                      
AS                    
BEGIN                    
 SET NOCOUNT ON;                    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;                    
 SET ARITHABORT ON;                    
   
 declare @total varchar(50)='';  
  
 DECLARE @lXML XML                    
   SET @lXML = CAST(@rPermissionStr2 AS xml)                   
   DECLARE @tbltmp TABLE                    
   (                    
  tid INT IDENTITY(1,1),t_freqid int,t_Ach int,t_month varchar(max),t_achid varchar(50),t_levelAssignid int  --,goalAltId int             
   )                   
   INSERT INTO @tbltmp                    
   SELECT                    
    T.c.value('@freqid','INT'),    
    T.c.value('@Achivement','INT')    
	,T.c.value('@MonthName','varchar(max)')
	,T.c.value('@Achievement_id','varchar(50)') 
	,T.c.value('@levelAssignid','INT') 
    FROM @lXML.nodes('/Permissions/Permission') AS T(c)                          
    MERGE kpms_FrqWise_Target_Achievement AS TARGET                    
    USING @tbltmp AS SOURCE ON emp_id = @Emp_ID                
 -- WHEN MATCHED THEN                  
 --UPDATE SET  [Ouater/monthid] = t_Fgrpid      
 --select @total = @total + Achievement from kpms_FrqWise_Target_Achievement where emp_id=21162 and freq_id = @freqid  
  WHEN NOT MATCHED BY TARGET THEN      
  INSERT                    
   (                    
		freq_id,Achievement,emp_id,Month,Achievement_id,levelAssignid  --,Achievement_id--,WeightageType  ,quter_monthid
   )                    
   VALUES                    
   (                   
	   t_freqid,t_Ach,@Emp_ID,t_month,t_achid,t_levelAssignid
   );      
   
 --  update kfta set TargetAchiveid = ktt.TargetAchiveid from kpms_FrqWise_Target_Achievement kfta 
	--join KPMS_T0110_TargetAchivement ktt on kfta.emp_id = ktt.emp_id
	--where ktt.TargetAchiveid = fta_id and kfta.emp_id = ktt.emp_id
  
	  END  
    
    
   select 1 as result;            
  