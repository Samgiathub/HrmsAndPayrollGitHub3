  
  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0030_Hrms_Training_Type]  
  @TRAINING_TYPE_ID  NUMERIC(18,0)OUT  
 ,@CMP_ID    NUMERIC(18,0)  
 ,@TRAINING_TYPENAME VARCHAR(100)    
 ,@TRANS_TYPE   VARCHAR(1)   
 ,@TYPE_OJT    NUMERIC(5,0) =NULL   
 ,@TYPE_INDUCTION  NUMERIC(5,0) =NULL  
 ,@Ind_Tran_Dept     Tinyint = 0 -- 1 For HR 2 For Functional Dept  
 ,@USER_ID NUMERIC(18,0) = 0 -- ADDED BY MUKTI 19082015  
 ,@IP_ADDRESS VARCHAR(30)= '' -- ADDED BY MUKTI 19082015  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  
  
--Added By Mukti 19082015(start)  
 DECLARE @OLDVALUE AS VARCHAR(MAX)  
 DECLARE @OLDTRAINING_TYPENAME VARCHAR(100)    
 DECLARE @OLDTYPE_OJT    VARCHAR(10)   
 DECLARE @OLDTYPE_INDUCTION   VARCHAR(10)  
 DECLARE @OLDIND_TRIN_DEPT   VARCHAR(10)  
--Added By Mukti 19082015(start)  
BEGIN  
   
 IF @TYPE_INDUCTION = 0   
    BEGIN  
      SET @IND_TRAN_DEPT = 0   
    END  
   set @Training_TypeName = dbo.fnc_ReverseHTMLTags(@Training_TypeName)  --added by Ronak 221021

 IF  UPPER(@TRANS_TYPE)  = 'I'  
  BEGIN  
   IF EXISTS(SELECT 1 FROM T0030_HRMS_TRAINING_TYPE WITH (NOLOCK) WHERE TRAINING_TYPENAME=@TRAINING_TYPENAME AND  CMP_ID=@CMP_ID)  
    BEGIN  
     --Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of Training Type name',0,'Duplicate name',GetDate(),'TrainingType')  
     SET @TRAINING_TYPE_ID=0  
     RETURN   
    END  
   ELSE  
    BEGIN  
     SELECT @TRAINING_TYPE_ID = ISNULL(MAX(TRAINING_TYPE_ID),0)+ 1 FROM T0030_HRMS_TRAINING_TYPE WITH (NOLOCK)  
     INSERT INTO T0030_HRMS_TRAINING_TYPE  
     (  
       TRAINING_TYPE_ID  
      ,TRAINING_TYPENAME  
      ,CMP_ID  
      ,TYPE_OJT  
      ,TYPE_INDUCTION   
      ,INDUCTION_TRANING_DEPT   )  
     VALUES  
     (  
       @TRAINING_TYPE_ID  
      ,@TRAINING_TYPENAME  
      ,@CMP_ID  
      ,@TYPE_OJT  
      ,@TYPE_INDUCTION  
      ,@IND_TRAN_DEPT   
     )  
    END  
 --Added By Mukti 19082015(start)  
       SET @OLDVALUE = 'New Value' + '#'+ 'Training Type Name:' + cast(Isnull(@Training_TypeName,'') as varchar(100)) + '#' +   
             'Company Id:' + cast(Isnull(@Cmp_id,0) as varchar(10)) + '#' +   
             'On the Job Training:' + cast(Isnull(@Type_OJT,0) as varchar(10)) + '#' +   
             'Type Induction:' + cast(Isnull(@Type_Induction,0) as varchar(10)) + '#' +   
             'Induction Training Dept:' + cast(Isnull(@IND_TRAN_DEPT,0) as varchar(10))  
 --Added By Mukti 19082015(end)  
  END  
 ELSE IF  UPPER(@TRANS_TYPE)  = 'U'  
  BEGIN  
   IF EXISTS(SELECT 1 FROM T0030_HRMS_TRAINING_TYPE WITH (NOLOCK) WHERE TRAINING_TYPENAME=@TRAINING_TYPENAME AND TRAINING_TYPE_ID<>@TRAINING_TYPE_ID AND CMP_ID=@CMP_ID)  
    BEGIN  
     --Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of Training Type name',0,'Duplicate name',GetDate(),'TrainingType')  
     SET @TRAINING_TYPE_ID=0  
     RETURN   
    END  
   ELSE  
    BEGIN  
    --ADDED BY MUKTI 19082015(START)  
     SELECT @OLDTRAINING_TYPENAME = TRAINING_TYPENAME,  
      @OLDTYPE_OJT = TYPE_OJT,  
      @OLDTYPE_INDUCTION = TYPE_INDUCTION,  
      @OLDIND_TRIN_DEPT = INDUCTION_TRANING_DEPT  
     FROM T0030_HRMS_TRAINING_TYPE WITH (NOLOCK)  
     WHERE CMP_ID=@CMP_ID AND TRAINING_TYPE_ID = @TRAINING_TYPE_ID  
    --ADDED BY MUKTI 19082015(END)   
   
     UPDATE T0030_HRMS_TRAINING_TYPE  
     SET   
      TRAINING_TYPENAME = @TRAINING_TYPENAME,  
      TYPE_OJT =@TYPE_OJT,  
      TYPE_INDUCTION=@TYPE_INDUCTION,  
      INDUCTION_TRANING_DEPT = @IND_TRAN_DEPT  
     WHERE CMP_ID=@CMP_ID AND TRAINING_TYPE_ID = @TRAINING_TYPE_ID  
       
    --Added By Mukti 19082015(start)  
       SET @OLDVALUE = 'Old Value' + '#'+ 'Training Type Name:' + cast(Isnull(@OldTraining_TypeName,'') as varchar(100)) + '#' +   
             'Company Id:' + cast(Isnull(@Cmp_id,0) as varchar(10)) + '#' +   
             'On the Job Training:' + cast(Isnull(@OldType_OJT,'') as varchar(10)) + '#' +   
             'Type Induction:' + cast(Isnull(@OldType_Induction,'') as varchar(10)) + '#' +   
             'Induction Training Dept:' + cast(Isnull(@OLDIND_TRIN_DEPT,0) as varchar(30)) + '#' +   
        'New Value' + '#'+ 'Training Type Name:' + cast(Isnull(@Training_TypeName,'') as varchar(100)) + '#' +   
             'Company Id:' + cast(Isnull(@Cmp_id,0) as varchar(10)) + '#' +   
             'On the Job Training:' + cast(Isnull(@Type_OJT,0) as varchar(10)) + '#' +   
             'Type Induction:' + cast(Isnull(@Type_Induction,0) as varchar(10)) + '#' +   
             'Induction Training Dept:' + cast(Isnull(@IND_TRAN_DEPT,0) as varchar(30))  
    --ADDED BY MUKTI 19082015(END)       
    END  
  END  
 ELSE IF  UPPER(@TRANS_TYPE)  = 'D'  
  BEGIN  
  --ADDED BY MUKTI 19082015(START)  
    SELECT @OLDTRAINING_TYPENAME = TRAINING_TYPENAME,  
        @OLDTYPE_OJT = TYPE_OJT,  
        @OLDTYPE_INDUCTION = TYPE_INDUCTION,  
        @OLDIND_TRIN_DEPT = INDUCTION_TRANING_DEPT  
    FROM T0030_HRMS_TRAINING_TYPE WITH (NOLOCK)  
    WHERE CMP_ID=@CMP_ID AND TRAINING_TYPE_ID = @TRAINING_TYPE_ID  
  --ADDED BY MUKTI 19082015(END)   
    
  IF NOT EXISTS(SELECT 1 FROM T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND TRAINING_TYPE=@TRAINING_TYPE_ID)  
   BEGIN  
    DELETE FROM T0030_HRMS_TRAINING_TYPE WHERE TRAINING_TYPE_ID = @TRAINING_TYPE_ID AND CMP_ID = @CMP_ID  
   END  
  ELSE  
   BEGIN  
    SET @TRAINING_TYPE_ID=0  
    RETURN  
   END  
   --Added By Mukti 19082015(start)  
       SET @OLDVALUE = 'Old Value' + '#'+ 'Training Type Name:' + cast(Isnull(@OldTraining_TypeName,'') as varchar(100)) + '#' +   
             'Company Id:' + cast(Isnull(@Cmp_id,0) as varchar(10)) + '#' +   
             'On the Job Training:' + cast(Isnull(@OldType_OJT,0) as varchar(10)) + '#' +   
             'Type Induction:' + cast(Isnull(@OldType_Induction,0) as varchar(10)) + '#' +   
             'Induction Training Dept:' + cast(Isnull(@OLDIND_TRIN_DEPT,0) as varchar(30))  
   --Added By Mukti 19082015(end)   
  END  
 EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRANS_TYPE,'Training Type',@OLDVALUE,@TRAINING_TYPE_ID,@USER_ID,@IP_ADDRESS  
END  
  