


-- P0030_BRANCH_MASTER_IMPORTS 9,'VAS','VASNA','Ahmedabad','1/p','','Gujarat66','I'
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_BRANCH_MASTER_IMPORTS]  
    @Cmp_ID   numeric(9)  
   ,@Branch_Code varchar(50)  
   ,@Branch_Name varchar(100)  
   ,@Branch_City varchar(30)  
   ,@Branch_Address varchar(2000)  
   ,@Comp_Name varchar(50)  
   ,@State_Name varchar(50) 
   ,@Country_Name varchar(50)  
   ,@Tran_type  varchar(1) 
   ,@GUID varchar(2000) 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Comment by nilesh patel on 11062016 After discussion Hardik Bhai 
/*
 Declare @Branch_ID  numeric(9)
 Declare @State_ID  numeric(9)
 
 Declare @Is_Contractor_Branch numeric(9)
 set @Is_Contractor_Branch =0
 
 Declare @User_Id numeric(18,0) 
 set @User_Id =0
 
 Declare @IP_Address varchar(30)
 set @IP_Address =''
   
 declare @loginname as varchar(50)  
 Declare @Domain_Name as varchar(50)  
 Declare @Pre_Code as varchar(50)  
 Declare @For_Date Datetime   
 Declare @Gen_ID  numeric   
 
   
  if @Comp_Name =''  
    set @Comp_Name =null  
    
   If @tran_type  = 'I' Or @tran_type = 'U'
	BEGIN 
		If @Branch_Code = ''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Enter Valid Branch Code',0,'Enter Valid Branch Code',GetDate(),'Branch Master')						
				Return
			END
		
		If @Branch_Name = ''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Enter Valid Branch Name',0,'Enter Valid Branch Name',GetDate(),'Branch Master')						
				Return
			END

		--If @State_ID = 0
		--	BEGIN
		--		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'State ID is not Properly Inserted',0,'Enter Proper State Id',GetDate(),'Branch Master')						
		--		Return
		--	END
	END
  
 If @tran_type  = 'I'  
  Begin  
  if exists (Select Branch_ID  from dbo.T0030_BRANCH_MASTER Where Upper(Branch_Name) = Upper(@Branch_Name) and Cmp_ID = @Cmp_ID)   
    begin  
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Branch Name already Exists.',0,'Branch Name Should be map with Branch Master',GetDate(),'Branch Master')						
		set @Branch_ID = 0  
		Return  
    end  
   
   if exists (Select Branch_ID  from dbo.T0030_BRANCH_MASTER Where Upper(Branch_Code) = Upper(@Branch_Code) and Cmp_ID = @Cmp_ID)   
    begin 
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Same Branch Code already Exists.',0,'Branch Code Should be map with Branch Master',GetDate(),'Branch Master')						 
		set @Branch_ID = 0  
		Return  
    end  
    
   
    select @State_ID = isnull(State_ID,0) from dbo.T0020_STATE_MASTER 
			Where Cmp_id = @Cmp_ID And Upper(State_Name) = Upper(@State_Name)
	
	if isnull(@State_ID,0) = 0
	begin
		set @State_ID = 0
	end

	If @State_ID = 0
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Enter Valid State Name',0,'State Name Should be map with State Master',GetDate(),'Branch Master')						
		Return
	END

    select @Branch_ID = Isnull(max(Branch_ID),0) + 1  From dbo.T0030_BRANCH_MASTER   
      
    INSERT INTO dbo.T0030_BRANCH_MASTER  
                          (Branch_ID, Cmp_ID, State_ID,Branch_Code, Branch_Name, Branch_City, Branch_Address,Comp_name,Is_Contractor_Branch)  
    VALUES     (@Branch_ID,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,@Branch_City,@Branch_Address,@Comp_name,@Is_Contractor_Branch)  
    
    select @Domain_Name = Domain_Name From  T0010_COMPANY_MASTER Where Cmp_ID = @Cmp_ID   
      
    set @loginname = @Branch_Code + @Domain_Name        
		
    --Here we Define Is_Defualt 3 for Branch User Which Automatically Defined.
    -- Insert Default General Setting   
    Select @For_Date = From_Date  From T0010_Company_Master Where Cmp_ID =@Cmp_ID  
    set @Gen_ID = 0 
        
    --Exec P0040_GENERAL_SETTING   @Gen_ID output ,@Cmp_ID,@Branch_ID,@For_Date,1,1,0,'00:00',0,1,0,0,1,1,0,0,0,'',0,0,0,1,0,0,0,'00:00','00:00','00:00','00:00',0,'00:00',1,15000,4.75,0,0,'00:00',0,0,0,0,0,@For_Date,0,1,'I'
 
    --Change By Paras 16-10-2012 
    Exec P0040_GENERAL_SETTING      @Gen_ID output ,@Cmp_ID,@Branch_ID,@For_Date,1,1,0,'00:00',0,1,0,0,1,1,0,0,0,'',0,0,0,1,0,0,0,'00:00','00:00','00:00','00:00',0,'00:00',1,15000,4.75,0,0,'00:00',0,0,0,0,0,@For_Date,0,1,'I',@For_Date,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0,0,0,0,0,'',0,0,0,'',0,0,0,0,'',0,0,0,'',0,0,0,0,1,0,0,'',0,0,'',0,0,0,0,'',0,0,0,0,'','',0,0,0,0,0,0,0,'',0,@User_Id,@IP_Address         
    -----------
       
    if @Gen_ID > 0   
    begin
		--Exec P0050_GENERAL_DETAIL 0,@Cmp_ID,@Gen_ID,3.67,12,1.1,8.33,0.5,0.01,15000,15000,'I'   --commented by Hardik 13/03/2015 as PF Rule changed A/c.2 percent 1.10 to 0.85 from 01/01/2015
		Exec P0050_GENERAL_DETAIL 0,@Cmp_ID,@Gen_ID,3.67,12,0.85,8.33,0.5,0.01,15000,15000,'I'   
	end
   */
 Begin
    Declare @Branch_ID  numeric(18,0)
    Set @Branch_ID = 0
    
    Declare @State_ID numeric(18,0)
    Set @State_ID = 0   
    Declare @Country_ID numeric(18,0)
    Set @Country_ID = 0
    
    select @State_ID = isnull(State_ID,0) from dbo.T0020_STATE_MASTER WITH (NOLOCK)
			Where Cmp_id = @Cmp_ID And Upper(State_Name) = Upper(@State_Name)
	
	select @Country_ID = isnull(Loc_ID,0) from dbo.T0001_Location_Master WITH (NOLOCK)
			Where Upper(Loc_name) = Upper(@Country_Name)
			 
    
    Exec P0030_BRANCH_MASTER @Branch_ID output,@Cmp_ID,@State_ID,@Branch_Code,@Branch_Name,@Branch_City,@Branch_Address,@Comp_Name,@tran_type,0,0,'',@Country_ID,0,0,'','','','',1,NULL,NULL,NULL,@GUID --change by ronakk 26072022
    
    
  End  


