CREATE TABLE [dbo].[T0130_AR_Approval_Detail] (
    [AR_AprDetaill_ID] NUMERIC (18)    NOT NULL,
    [AR_App_ID]        NUMERIC (18)    NULL,
    [AR_Apr_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [Increment_ID]     NUMERIC (18)    NULL,
    [For_Date]         DATETIME        NOT NULL,
    [AD_ID]            NUMERIC (18)    NOT NULL,
    [AD_Flag]          CHAR (10)       NOT NULL,
    [AD_Mode]          NVARCHAR (50)   NULL,
    [AD_Percentage]    NUMERIC (18, 2) NULL,
    [AD_Amount]        NUMERIC (18, 2) NULL,
    [E_AD_Max_Limit]   NUMERIC (18, 2) NULL,
    [Comments]         VARCHAR (255)   NULL,
    [CreatedBy]        NUMERIC (18)    NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [Modifiedby]       NUMERIC (18)    NULL,
    [DateModified]     DATETIME        NULL,
    CONSTRAINT [PK_T0130_AR_Approval_Detail] PRIMARY KEY CLUSTERED ([AR_AprDetaill_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0130_AR_Approval_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0130_AR_Approval_Detail_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0130_AR_Approval_Detail_T0100_AR_Application] FOREIGN KEY ([AR_App_ID]) REFERENCES [dbo].[T0100_AR_Application] ([AR_App_ID]),
    CONSTRAINT [FK_T0130_AR_Approval_Detail_T0120_AR_Approval] FOREIGN KEY ([AR_Apr_ID]) REFERENCES [dbo].[T0120_AR_Approval] ([AR_Apr_ID])
);


GO



CREATE TRIGGER [DBO].[Tri_T0130_AR_Approval_Detail_delete]  
ON [dbo].[T0130_AR_Approval_Detail]  
FOR  DELETE    
AS  
SET NOCOUNT ON  
 BEGIN

   DECLARE @APR_APRDETAIL_ID NUMERIC(18,0)
   DECLARE @AR_APR_ID NUMERIC(18,0)
   DECLARE @EMP_id NUMERIC(18,0)
   DECLARE @CMP_ID NUMERIC(18,0)
   DECLARE @AD_id NUMERIC(18,0)
   DECLARE @for_date datetime
   declare @Increment_ID as numeric(18,0)
   
   IF eXISTS(SELECT 1 FROM DELETED)
   BEGIN

	Declare curautoshift cursor Fast_forward for	                  
	select  CMP_ID,Emp_ID,AD_ID,inCREMENT_id from DELETED  												
	Open curautoshift                      
	  Fetch next from curautoshift into @Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID               
		While @@fetch_status = 0                    
			Begin     
             
          
               select @for_date = MAX(Increment_Effective_Date) from T0095_INCREMENT where cmp_ID=@Cmp_ID and emp_ID=@Emp_ID 
				
				delete FROM T0100_EMP_EARN_DEDUCTION where cmp_ID=@Cmp_ID and emp_ID=@Emp_ID  and ad_ID=@AD_ID --and Increment_ID=@Increment_ID
				
				
			
    fetch next from curautoshift into  @Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID
   end                    
 close curautoshift                    
 deallocate curautoshift    
  
  eND 
  
   
   
 END



GO



CREATE TRIGGER [DBO].[Tri_T0130_AR_Approval_Detail]  
ON [dbo].[T0130_AR_Approval_Detail]  
FOR  INSERT
AS  
SET NOCOUNT ON  
 BEGIN

  DECLARE @APR_STATUS AS NUMERIC(1,0)
  DECLARE @APR_ID AS NUMERIC(18,0)
  DECLARE @Cmp_ID AS NUMERIC(18,0)
  DECLARE @Emp_ID AS NUMERIC(18,0)  
  DECLARE @APR_DETAIL_ID NUMERIC(18,0)
  DECLARE @AR_APP_ID NUMERIC(18,0)
  DECLARE @AR_APR_ID NUMERIC(18,0)  
  DECLARE @AD_ID NUMERIC(18,0)
  DECLARE @AD_MODE NVARCHAR(250)
  DECLARE @AD_PERCENTAGE NVARCHAR(250)
  DECLARE @AD_AMOUNT NUMERIC(18,2)
  DECLARE @AD_Flag char(10)
  DECLARE @E_AD_Max_Limit NUMERIC(18,2)
  DECLARE @Comments nvarchar(255)
  DECLARE @Increment_ID numeric(18,2)
  declare @For_Date as datetime
  declare @AD_TRAN_ID as numeric(18,0)
  
   
 
  SELECT  @APR_STATUS = APR_Status,@Cmp_ID=Cmp_ID,@Increment_ID= Increment_Id,@Emp_ID=Emp_ID FROM T0120_AR_Approval where AR_Apr_ID in (SELECT AR_Apr_ID from INSERTED)
 
  
   IF ISNULL(@APR_STATUS,0) = 1
   BEGIN
	
	Declare @Emp_ID_AutoShift numeric
	Declare @In_Time_Autoshift datetime
	Declare @New_Shift_ID numeric
	Declare curautoshift cursor Fast_forward for	                  
	select  CMP_ID,
			Emp_ID,
			AD_ID,
			@Increment_ID,
			For_Date,
			AD_Flag,
			AD_Mode,
			AD_Percentage,
			AD_Amount,
			E_AD_Max_Limit
			from INSERTED where cmp_ID=@Cmp_ID 
	Open curautoshift                      
	  Fetch next from curautoshift into @Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID,@For_Date,@AD_Flag,@AD_MODE,@AD_PERCENTAGE,@AD_AMOUNT,@E_AD_Max_Limit
               
		While @@fetch_status = 0                    
			Begin     
             
				SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0100_EMP_EARN_DEDUCTION 
				
				select @For_Date = Increment_Effective_Date from T0095_Increment where Increment_ID = @Increment_ID
				
				if exists(select AD_TRAN_ID from T0100_EMP_EARN_DEDUCTION where CMP_ID = @CMP_ID and EMP_ID = @EMP_ID and AD_ID = @AD_ID and INCREMENT_ID = @INCREMENT_ID)
					Begin
						select @AD_TRAN_ID = AD_TRAN_ID from T0100_EMP_EARN_DEDUCTION where CMP_ID = @CMP_ID and EMP_ID = @EMP_ID and AD_ID = @AD_ID and INCREMENT_ID = @INCREMENT_ID
						
						update T0100_EMP_EARN_DEDUCTION set
							INCREMENT_ID = @INCREMENT_ID,
							FOR_DATE = @FOR_DATE,
							E_AD_FLAG = @AD_Flag,
							E_AD_MODE = @AD_MODE,
							E_AD_PERCENTAGE = @AD_PERCENTAGE,
							E_AD_AMOUNT = @AD_AMOUNT,
							E_AD_MAX_LIMIT = @E_AD_Max_Limit,
							E_AD_YEARLY_AMOUNT = 0
						Where AD_TRAN_ID = @AD_TRAN_ID
					End
				else
					Begin
						INSERT INTO T0100_EMP_EARN_DEDUCTION
							   (AD_TRAN_ID,EMP_ID,CMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,
								E_AD_AMOUNT,E_AD_MAX_LIMIT,E_AD_YEARLY_AMOUNT)
						VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@FOR_DATE,@AD_Flag,@AD_MODE,@AD_PERCENTAGE,
								@AD_AMOUNT,@E_AD_Max_Limit,0)
					End
				
			
    fetch next from curautoshift into  @Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID,@For_Date,@AD_Flag,@AD_MODE,@AD_PERCENTAGE,@AD_AMOUNT,@E_AD_Max_Limit                  
   end                    
 close curautoshift                    
 deallocate curautoshift    
   		
   END
   

   
 END


