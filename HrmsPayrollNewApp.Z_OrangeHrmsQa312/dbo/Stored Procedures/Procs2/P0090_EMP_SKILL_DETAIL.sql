  
  
  
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
  
CREATE PROCEDURE [dbo].[P0090_EMP_SKILL_DETAIL]  
   @Row_ID numeric(18,0) output  
  ,@Emp_ID as numeric(18,0)  
  ,@Cmp_ID numeric(18,0)  
  ,@Skill_ID numeric   
  ,@Skill_Comments varchar(250)  
  ,@Skill_Experience varchar(50)    
  ,@tran_type varchar(1)  
  ,@Login_Id numeric(18,0)=0 -- Rathod '18/04/2012'  
   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  if @Skill_ID = 0   
  set @Skill_ID =  null  
     set @Skill_Comments = dbo.fnc_ReverseHTMLTags(@Skill_Comments)  --added by Ronak 100121  
   if @tran_type ='i'   
   begin  
      
    IF exists(select Skill_ID From T0090_EMP_SKILL_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Skill_ID = @Skill_ID)  
     begin  
       set @Row_ID = 0  
       return  
     end  
     
     
    select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_EMP_SKILL_DETAIL WITH (NOLOCK)  
     
     
    INSERT INTO T0090_EMP_SKILL_DETAIL  
                          (Row_ID,Emp_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience)  
    VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience)  
      
    INSERT INTO T0090_EMP_SKILL_DETAIL_Clone  
               (Row_ID,Emp_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience,System_Date,Login_Id)  
    VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience,GETDATE(),@Login_Id)    
        
      
   end   
 else if @tran_type ='u'   
    begin  
      
    IF not exists(select Skill_ID From T0090_EMP_SKILL_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Row_ID = @Row_ID) -- Change condition Alpesh 22-Jul-2011  
     begin  
      set @Row_ID = 0  
      return  
     end  
       
    IF exists(select Skill_ID From T0090_EMP_SKILL_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Skill_ID = @Skill_ID and Row_ID <> @Row_ID) --Changed By Gadriwala  22032014(RowID <> @Row_ID condition add)  
     begin     
      set @Row_ID = 0  
      return  
     end  
       
     UPDATE    T0090_EMP_SKILL_DETAIL  
     SET              Cmp_ID = @Cmp_ID,Emp_ID = @Emp_ID ,Skill_ID = @Skill_ID, Skill_Comments = @Skill_Comments, Skill_Experience = @Skill_Experience  
     WHERE     (Row_ID = @Row_ID and Emp_ID = @Emp_ID )  
       
     INSERT INTO T0090_EMP_SKILL_DETAIL_Clone  
               (Row_ID,Emp_ID,Cmp_ID, Skill_ID, Skill_Comments,Skill_Experience,System_Date,Login_Id)  
    VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience,GETDATE(),@Login_Id)   
    end  
 else if @tran_type ='d'  
     delete  from T0090_EMP_SKILL_DETAIL where Row_ID = @Row_ID  
       
       
 RETURN  
  
  
  
  