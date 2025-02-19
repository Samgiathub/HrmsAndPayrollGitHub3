

-- =============================================  
-- Author:  zalak shah  
-- ALTER date: 5 Oct 2010  
-- Description: <for Designation chart at user> 
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================  
CREATE PROCEDURE [dbo].[SP_GET_ORGANIZATION_TREE_UP]       
 @cmp_id as numeric,  
 @branch_id as NUMERIC,  
 @emp_id as NUMERIC,  
 @int_level as NUMERIC,  
 @MaxLevel as NUMERIC 
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 BEGIN  
  if @branch_id = 0  
   set @branch_id = null  
        if @emp_id = 0   
   set @emp_id= null  
  
  --Change by ronakk 05112022  Emp_Code => Alpha_Emp_Code

  DECLARE @Row_No NUMERIC  
  IF @int_level = 0    
   BEGIN  
    SET @Row_No = 0  
    SET @Int_Level= 0  
    SELECT @Row_No = isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
    IF isnull(@emp_id,0) <> 0  
       BEGIN  
       print 'm'
       PRINT @emp_id
        IF NOT EXISTS(SELECT 1 FROM TBL_ORGANIZATION_DISPLAY WITH (NOLOCK) WHERE Emp_id=@emp_id)
			BEGIN
			 Insert Into TBL_ORGANIZATION_DISPLAY  
			 (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)  
			 SELECT @Row_No, emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + '<b> (' + Desig_name + ')<b/> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main 
			 FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_id = @emp_id and emp_left<>'Y'   
			 
			  SELECT @emp_id=emp_id FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_id = @emp_id and emp_left<>'Y'   
			END
		--select * from TBL_ORGANIZATION_DISPLAY
		END  
     ELSE IF isnull(@branch_id,0)<>0   
		BEGIN  
			 Insert Into TBL_ORGANIZATION_DISPLAY  
			 (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,is_main)  
			 SELECT @Row_No,emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b> (' + Desig_name + ')</b> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main 
			 FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and Is_main=1 and emp_left<>'Y'  
		  
			 SELECT @emp_id=emp_id FROM V0080_Employee_master WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and Is_main=1 and emp_left<>'Y'  
		END  
	ELSE  
		 BEGIN  
		  IF NOT EXISTS(SELECT 1 FROM TBL_ORGANIZATION_DISPLAY WITH (NOLOCK) WHERE Emp_id=@emp_id)
			BEGIN
			 print 'K'
			 PRINT @emp_id
			 INSERT INTO TBL_ORGANIZATION_DISPLAY  
			 (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,is_main)  
			 SELECT @Row_No,emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b>(' + Desig_name + ')</b> ',desig_id,Def_id,@Int_Level,Parent_id,0,Is_main 
			 FROM V0080_Employee_master WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and emp_left<>'Y'  
		  
			 SELECT @emp_id=emp_id FROM V0080_Employee_master WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and emp_left<>'Y'  
			 END
		 END  
   END  
   
  SET @Int_Level= @Int_Level + 1  
    
 if @Int_Level = @MaxLevel   
   begin  
    return  
   end  
  Declare @Emp_id1 numeric(18, 0)   
  Declare @Emp_name varchar(500)   
  Declare @Desig_id numeric(18, 0)   
  Declare @Def_id  numeric(18, 0)   
  Declare @Parent_id numeric(18, 0)  
  declare @Is_main numeric(18, 0)  
  
   
  declare @emp_superior as numeric(18, 0) 
   SELECT @emp_superior=emp_superior  
   FROM V0080_Employee_master   
   WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_id = @emp_id order by emp_full_name  
     
    
  Declare curUser cursor Local for   
  SELECT Emp_id,cast(Alpha_Emp_Code as varchar(50)) + ' - ' + Emp_full_name + ' <b>(' + Desig_name + ')</b> ',Desig_id,Def_id,Parent_id,is_main  
--<br> Branch Name : ' + isnull(branch_name,'')  + '<br> Grade Name : ' + isnull(grd_name,'') + ' <br> Deparment : ' + isnull(dept_name,'nt assigned')  
  FROM V0080_Employee_master   
  WHERE cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_id = @emp_superior and emp_left<>'Y' order by emp_full_name  
     
   open curUser  
     
   Fetch next from curUser Into @Emp_id1, @Emp_name, @Desig_id,@Def_id,@Parent_id,@Is_main  
   while @@Fetch_Status = 0  
    begin  
	 select @Row_No = isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)  
	   IF NOT EXISTS(SELECT 1 FROM TBL_ORGANIZATION_DISPLAY WITH (NOLOCK) WHERE Emp_id=@Emp_id1)
		BEGIN
			 Insert Into TBL_ORGANIZATION_DISPLAY   
			 (Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)  
			 values   
			 (@Row_No,@Emp_id1,@Emp_name,@Desig_id,@Def_id,@Int_Level,@Parent_id,0,@Is_main)  
		 END
     Exec SP_GET_ORGANIZATION_TREE_UP @cmp_id,@branch_id,@emp_id1,@int_level,@MaxLevel   
         
    Fetch next from curUser Into @Emp_id1, @Emp_name, @Desig_id,@Def_id,@Parent_id,@Is_main  
    End  
  
   Close curUser  
   Deallocate curUser  
 RETURN  
END  




