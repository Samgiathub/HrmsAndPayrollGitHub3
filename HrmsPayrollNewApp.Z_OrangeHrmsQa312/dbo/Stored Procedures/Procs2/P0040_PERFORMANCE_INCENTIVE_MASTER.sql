    
    
    
    
    
--Created By Girish on 30-Nov-2009    
    
CREATE PROCEDURE [dbo].[P0040_PERFORMANCE_INCENTIVE_MASTER]    
 @PER_INC_TRAN_ID NUMERIC(18,0) OUTPUT    
,@CMP_ID          NUMERIC(18,0)    
,@PER_NAME        VARCHAR(50)    
,@PER_DESC        VARCHAR(150)    
,@TOTAL_POINTS    NUMERIC(18,1)    
,@APPROVE_FROM    VARCHAR(15)    
,@TRAN_TYPE       VARCHAR(1)    
,@User_Id numeric(18,0) = 0    
,@IP_Address varchar(30)= '' --Add By Paras 18-10-2012    
AS    
    
        SET NOCOUNT ON     
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
  SET ARITHABORT ON    
    
    
declare @OldValue as varchar(Max)    
declare @OldPER_NAME as varchar(50)    
declare @OldPER_DESC as varchar(150)    
declare @OldTOTAL_POINTS as varchar(20)    
declare @OldAPPROVE_FROM as varchar(15)    
    
set @OldPER_NAME = ''    
set @OldPER_DESC = ''    
set @OldTOTAL_POINTS = ''    
set @OldAPPROVE_FROM = ''    
    
    
       set @PER_NAME = dbo.fnc_ReverseHTMLTags(@PER_NAME)  --added by mansi 061021   
	    set @PER_DESC = dbo.fnc_ReverseHTMLTags(@PER_DESC)  --added by mansi 061021   
		  

IF UPPER(@TRAN_TYPE ) = 'I'    
 BEGIN    
   IF EXISTS(SELECT PER_INC_TRAN_ID FROM T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND UPPER(PER_NAME)=UPPER(@PER_NAME))    
    BEGIN    
     SET @PER_INC_TRAN_ID=0    
     RETURN    
    END    
       
   SELECT  @PER_INC_TRAN_ID = ISNULL(MAX(PER_INC_TRAN_ID),0)+1 FROM T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK)    
       
   INSERT INTO T0040_PERFORMANCE_INCENTIVE_MASTER    
      (PER_INC_TRAN_ID,CMP_ID,PER_NAME,PER_DESC,TOTAL_POINTS,APPROVE_FROM,SYS_DATE)    
   VALUES(@PER_INC_TRAN_ID,@CMP_ID,@PER_NAME,@PER_DESC,@TOTAL_POINTS,@APPROVE_FROM,GETDATE())    
       
   set @OldValue = 'New Value' + '#'+ 'Performance Name  :' +ISNULL( @PER_NAME ,'') + '#' + 'Performance Description:' + ISNULL( @PER_DESC,'') + '#' + 'Total Points :' + CAST(ISNULL(@TOTAL_POINTS,0) AS VARCHAR(20)) + '#' + 'Approve Form :' +ISNULL(@APPROVE_FROM,0) + '#'     
        
 END    
ELSE IF UPPER(@TRAN_TYPE ) = 'U'    
 BEGIN    
   IF EXISTS(SELECT PER_INC_TRAN_ID FROM T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND UPPER(PER_NAME)=UPPER(@PER_NAME) AND PER_INC_TRAN_ID <> @PER_INC_TRAN_ID)    
    BEGIN    
     SET @PER_INC_TRAN_ID=0    
     RETURN    
    END    
      
    select @OldPER_NAME  =ISNULL(PER_NAME,'') ,@OldPER_DESC   =ISNULL(PER_DESC ,''),@OldTOTAL_POINTS  =isnull(TOTAL_POINTS,0),@OldAPPROVE_FROM  =isnull(APPROVE_FROM,'') From dbo.T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PER_INC_TRAN_ID = @PER_INC_TRAN_ID    
        
   UPDATE T0040_PERFORMANCE_INCENTIVE_MASTER     
   SET PER_NAME=@PER_NAME    
      ,PER_DESC=@PER_DESC    
      ,TOTAL_POINTS=@TOTAL_POINTS    
      ,APPROVE_FROM=@APPROVE_FROM    
      ,SYS_DATE=GETDATE()    
   WHERE PER_INC_TRAN_ID=@PER_INC_TRAN_ID AND CMP_ID=@CMP_ID    
       
   set @OldValue = 'old Value' +  '#'+ 'Performance Name  :' +ISNULL( @OldPER_NAME ,'') + '#' + 'Performance Description:' + ISNULL( @OldPER_DESC,'') + '#' + 'Total Points :' + CAST(ISNULL(@OldTOTAL_POINTS,0) AS VARCHAR(20)) + '#' + 'Approve Form :' +ISNULL(@OldAPPROVE_FROM,'') + '#'     
               + 'New Value' + '#'+ 'Performance Name  :' +ISNULL( @PER_NAME ,'') + '#' + 'Performance Description:' + ISNULL( @PER_DESC,'') + '#' + 'Total Points :' + CAST(ISNULL(@TOTAL_POINTS,0) AS VARCHAR(20)) + '#' + 'Approve Form:' +ISNULL(@APPROVE_FROM,0) + '#'     
      
 END    
ELSE IF UPPER(@TRAN_TYPE ) = 'D'     
 BEGIN    
 select @OldPER_NAME  =ISNULL(PER_NAME,'') ,@OldPER_DESC   =ISNULL(PER_DESC ,''),@OldTOTAL_POINTS  =isnull(TOTAL_POINTS,0),@OldAPPROVE_FROM  =isnull(APPROVE_FROM,'') From dbo.T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and PER_INC_TRAN_ID = @PER_INC_TRAN_ID    
   DELETE FROM T0040_PERFORMANCE_INCENTIVE_MASTER WHERE PER_INC_TRAN_ID=@PER_INC_TRAN_ID AND CMP_ID=@CMP_ID    
       
   set @OldValue = 'old Value' +  '#'+ 'Performance Name  :' +ISNULL( @OldPER_NAME ,'') + '#' + 'Performance Description:' + ISNULL( @OldPER_DESC,'') + '#' + 'Total Points :' + CAST(ISNULL(@OldTOTAL_POINTS,0) AS VARCHAR(20)) + '#' + 'Approve Form:' +ISNULL(@OldAPPROVE_FROM,'') + '#'     
 END    
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Perform Master',@OldValue,@PER_INC_TRAN_ID,@User_Id,@IP_Address  RETURN    
    
    
    