CREATE TABLE [dbo].[T0055_Resume_Master] (
    [Resume_Id]                   NUMERIC (18)    NOT NULL,
    [Cmp_id]                      NUMERIC (18)    NOT NULL,
    [Rec_Post_Id]                 NUMERIC (18)    NULL,
    [Resume_Posted_date]          DATETIME        NULL,
    [Initial]                     VARCHAR (50)    NULL,
    [Emp_First_Name]              VARCHAR (50)    NOT NULL,
    [Emp_Second_Name]             VARCHAR (50)    NULL,
    [Emp_Last_Name]               VARCHAR (50)    NOT NULL,
    [Date_Of_Birth]               DATETIME        NOT NULL,
    [Marital_Status]              VARCHAR (20)    NULL,
    [Gender]                      CHAR (1)        NULL,
    [Present_Street]              NVARCHAR (250)  NULL,
    [Present_City]                VARCHAR (50)    NULL,
    [Present_State]               VARCHAR (50)    NULL,
    [Present_Post_Box]            VARCHAR (20)    NULL,
    [Permanent_Street]            NVARCHAR (250)  NULL,
    [Permanent_City]              VARCHAR (50)    NULL,
    [Permanent_State]             VARCHAR (50)    NULL,
    [Permanentt_Post_Box]         VARCHAR (50)    NULL,
    [Home_Tel_no]                 VARCHAR (50)    NULL,
    [Mobile_No]                   VARCHAR (50)    NULL,
    [Primary_email]               VARCHAR (100)   NULL,
    [Other_Email]                 VARCHAR (100)   NULL,
    [Non_Technical_Skill]         VARCHAR (500)   NULL,
    [Cur_CTC]                     NUMERIC (18, 2) NULL,
    [Exp_CTC]                     NUMERIC (18, 2) NULL,
    [Total_Exp]                   NUMERIC (18, 2) NULL,
    [Resume_Name]                 VARCHAR (50)    NULL,
    [File_Name]                   VARCHAR (100)   NULL,
    [Resume_Status]               TINYINT         NULL,
    [Final_CTC]                   NUMERIC (18, 2) NULL,
    [Date_Of_Join]                DATETIME        NULL,
    [Basic_Salary]                NUMERIC (18, 2) NULL,
    [Emp_Full_PF]                 NUMERIC (18, 2) NULL,
    [Emp_Fix_Salary]              NUMERIC (18, 2) NULL,
    [Present_Loc]                 NUMERIC (18)    NULL,
    [Permanent_Loc_ID]            NUMERIC (18)    NULL,
    [System_Date]                 DATETIME        NULL,
    [Resume_Code]                 VARCHAR (50)    NULL,
    [HasPancard]                  INT             CONSTRAINT [DF_T0055_Resume_Master_HasPancard] DEFAULT ((0)) NULL,
    [PanCardNo]                   VARCHAR (50)    NULL,
    [PanCardAck_Path]             VARCHAR (100)   NULL,
    [Address_Proof]               VARCHAR (MAX)   NULL,
    [ConfirmJoining]              INT             CONSTRAINT [DF_T0055_Resume_Master_ConfirmJoining] DEFAULT ((0)) NULL,
    [Comments]                    VARCHAR (200)   NULL,
    [FatherName]                  VARCHAR (100)   NULL,
    [Lock]                        INT             CONSTRAINT [DF_T0055_Resume_Master_Lock] DEFAULT ((0)) NULL,
    [Identity_Proof]              VARCHAR (MAX)   NULL,
    [Present_District]            VARCHAR (50)    NULL,
    [Present_PO]                  VARCHAR (50)    NULL,
    [Permanent_District]          VARCHAR (50)    NULL,
    [Permanent_PO]                VARCHAR (50)    NULL,
    [DocumentType_Identity]       INT             NULL,
    [PanCardProof]                VARCHAR (MAX)   NULL,
    [PanCardAck_No]               VARCHAR (30)    NULL,
    [DocumentType_Address_Proof]  INT             NULL,
    [DocumentType_Identity2]      INT             NULL,
    [Identity_Proof2]             VARCHAR (MAX)   NULL,
    [DocumentType_AddressProof2]  INT             NULL,
    [Address_Proof2]              VARCHAR (MAX)   NULL,
    [DocumentType_Marriage_Proof] INT             NULL,
    [Marriage_Proof]              VARCHAR (MAX)   NULL,
    [Source_type_id]              NUMERIC (18)    NULL,
    [Source_Id]                   NUMERIC (18)    NULL,
    [Marriage_Date]               DATETIME        NULL,
    [Resume_ScreeningStatus]      INT             NULL,
    [Resume_ScreeningBy]          NUMERIC (18)    NULL,
    [Archive]                     INT             CONSTRAINT [DF_T0055_Resume_Master_Archive] DEFAULT ((0)) NULL,
    [is_physical]                 TINYINT         CONSTRAINT [DF_T0055_Resume_Master_is_physical] DEFAULT ((0)) NOT NULL,
    [Source_Name]                 VARCHAR (100)   NULL,
    [Aadhar_CardNo]               VARCHAR (50)    NULL,
    [Aadhar_CardPath]             VARCHAR (100)   NULL,
    [StateDomicile]               NUMERIC (18)    NULL,
    [PlaceofBirth]                VARCHAR (150)   NULL,
    [TrainingSeminars]            VARCHAR (500)   NULL,
    [jobProfile]                  VARCHAR (500)   NULL,
    [Location_Preference]         VARCHAR (1000)  NULL,
    [Response_of_Candidate]       VARCHAR (100)   NULL,
    [Response_Comments]           VARCHAR (1000)  DEFAULT ('') NOT NULL,
    [Transfer_CmpId]              NUMERIC (18)    NULL,
    [Transfer_RecPostId]          NUMERIC (18)    NULL,
    [Transfer_LocationId]         NUMERIC (18)    NULL,
    [Transfer_ResumeId]           NUMERIC (18)    NULL,
    [Religion]                    VARCHAR (50)    DEFAULT ('') NOT NULL,
    [Caste]                       VARCHAR (50)    DEFAULT ('') NOT NULL,
    [Caste_Category]              VARCHAR (50)    DEFAULT ('') NOT NULL,
    [No_Of_children]              INT             NULL,
    [Shirt_Size]                  VARCHAR (20)    DEFAULT ('') NOT NULL,
    [Pant_Size]                   VARCHAR (20)    DEFAULT ('') NOT NULL,
    [Shoe_Size]                   VARCHAR (20)    DEFAULT ('') NOT NULL,
    [Is_Physical_Disable]         TINYINT         NULL,
    [Physical_Disable_Perc]       FLOAT (53)      NULL,
    [Video_Resume]                NVARCHAR (MAX)  NULL,
    [Nationality]                 VARCHAR (150)   DEFAULT ('') NOT NULL,
    [Mother_Tongue]               VARCHAR (100)   DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_T0055_Resume_Master_1] PRIMARY KEY CLUSTERED ([Resume_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0055_Resume_Master_T0001_LOCATION_MASTER] FOREIGN KEY ([Present_Loc]) REFERENCES [dbo].[T0001_LOCATION_MASTER] ([Loc_ID]),
    CONSTRAINT [FK_T0055_Resume_Master_T0001_LOCATION_MASTER1] FOREIGN KEY ([Permanent_Loc_ID]) REFERENCES [dbo].[T0001_LOCATION_MASTER] ([Loc_ID])
);


GO



-----------------------------------------------
  --ALTER By : Nilay 06 May 2010
  --Getting the Approval Date for All Applicant
-----------------------------------------------
CREATE TRIGGER [DBO].[TRI_T0055_Resume_Master]
ON dbo.T0055_Resume_Master
FOR  update
AS
	
	Declare @Resume_Status as numeric(18,0)
	Declare @cmp_ID as numeric(18,0)
	Declare @Resume_ID as numeric(18,0)
	Declare @System_Date as DateTime
	dECLARE @TRAN_id AS NUMERIC
	
    Select  @Resume_Status =Resume_Status ,@cmp_ID =Cmp_ID,
			@Resume_ID=Resume_ID,@System_Date=System_date from inserted
			
			
    if @Resume_ID > 0 
            Begin
				if exists(Select Tran_ID from T0055_REsume_Approval_Status where Resume_ID =@Resume_ID and Resume_Status=@Resume_Status and Cmp_ID=@Cmp_ID)
				  Begin 
						set @Tran_ID = 0  
				  End
				
				/*SELECT @Tran_id =ISNULL(MAX(Tran_ID),0) +1 FROM T0055_RESUME_APPROVAL_STATUS
		
				Delete from T0055_RESUME_APPROVAL_STATUS where Resume_ID=@Resume_ID and Cmp_ID=@Cmp_ID
			
				Insert into T0055_RESUME_APPROVAL_STATUS 
				  (Tran_ID,Resume_ID,Resume_Status,Cmp_ID,Approval_Date)values
				  (@Tran_id,@Resume_ID,@Resume_Status,@cmp_ID,getdate())
				  */
				
			end
      
      Return



GO



CREATE TRIGGER Tri_T0055_Resume_Master_2
ON dbo.T0055_Resume_Master
FOR   UPDATE
AS
	declare @App_Id as numeric(18,0)
	declare @resume_Id as numeric(18,0)
	declare @basic_Salary as numeric(18,0)
----------------------------------------------------------------------------------------------------------------
------------------------------------------ Created By : Falak on 14-may-2010 -----------------------------------
----------------------------------------------------------------------------------------------------------------
------------------------------------------ Change on 21-May-2010 by Falak --------------------------------------
	
	set @App_Id = 0
	
	select @resume_id = resume_Id,@basic_Salary = Basic_Salary from inserted
	

	
	IF UPDATE(Basic_Salary)
	begin
		if @basic_Salary > 0 
		begin
			if exists(select App_Id from T0090_App_Master where Resume_Id = @resume_Id)
			begin
				select @App_Id = App_Id from T0090_App_Master where Resume_Id = @resume_Id
			
				--Update query for T0090_App_MAster
				Update T0090_App_Master set 
							Branch_Id = Rec.Branch_Id ,
							Grade_Id = Rec.Grade_Id,
							Dept_Id = Rec.Dept_ID,
							Desig_Id = Rec.Desi_Id,
							Type_Id = Rec.Type_Id,
							Shift_Id = Emp.Shift_Id,
							Initial = Re.Initial,
							App_First_Name = Re.Emp_First_Name,
							App_Middle_Name = Re.Emp_Second_Name,
							App_Last_Name = Re.Emp_Last_Name,
							Date_Of_Join = Re.Date_Of_Join,
							Basic_Salary = Re.Basic_Salary,
							Gender = Re.Gender,
							Marital_Status = Re.Marital_Status,
							Date_Of_Birth = Re.Date_Of_Birth,
							Primary_Email = Re.Primary_Email,
							Other_Email = Re.Other_Email,
							Present_Street = Re.Present_Street,
							Present_City = Re.Present_City,
							Present_State = Re.Present_State,
							Present_Post_Box = Re.Present_Post_Box,
							Present_Loc = Re.Present_Loc,
							Home_Tel_No = Re.Mobile_No,
							Mobile_No = Re.Mobile_No,
							Permanent_Street = Re.Permanent_Street,
							Permanent_City = Re.Permanent_City,
							Permanent_State = Re.Permanent_State,
							Permanent_Post_Box = Re.Permanentt_Post_Box,
							App_Full_Name = Re.Initial + ' ' + Re.Emp_First_Name + ' '+ 
								isnull(Re.Emp_Second_Name,'')+ ' ' + Re.Emp_Last_Name ,
						    Status =0		
								
								from
								
							inserted as Re inner join T0052_hrms_posted_Recruitment as Pos on
							re.REc_Post_Id = Pos.Rec_Post_ID inner join T0050_HrMS_Recruitment_REquest as Rec on
							pos.rec_req_Id = rec.Rec_Req_Id inner join T0080_Emp_master as Emp on
							Rec.S_Emp_Id = Emp.Emp_Id,T0090_App_Master as App where App.App_id = @App_Id 
			end
			else
			begin
				select @App_Id = isnull(max(App_Id),0) + 1 from T0090_App_Master
			
				Insert into T0090_App_Master (
							App_Id,
							Resume_Id,
							Cmp_Id,
							Branch_Id,
							Grade_Id,
							Dept_Id,
							Desig_Id,
							Type_Id,
							Shift_Id,
							Initial,
							App_First_Name,
							App_Middle_Name,
							App_Last_Name,
							Date_Of_Join,
							Basic_Salary,
							Gender,
							Marital_Status,
							Date_Of_Birth,
							Primary_Email,
							Other_Email,
							Present_Street,
							Present_City,
							Present_State,
							Present_Post_Box,
							Present_Loc,
							Home_Tel_No,
							Mobile_No,
							Permanent_Street,
							Permanent_City,
							Permanent_State,
							Permanent_Post_Box,
							App_Full_Name,
							Status 
						) 
						select  @App_Id,
								@resume_Id,
								Re.cmp_Id,
								Rec.Branch_Id,
								Rec.Grade_ID,
								Rec.Dept_ID,
								Rec.Desi_Id,
								Rec.Type_Id,
								Emp.Shift_Id,
								Re.Initial,
								Re.Emp_First_Name,
								Re.Emp_Second_Name,
								Re.Emp_Last_Name,
								Re.Date_Of_Join,
								Re.Basic_Salary,
								Re.Gender,
								Re.Marital_Status,
								Re.Date_Of_Birth,
								Re.Primary_Email,
								Re.Other_Email,
								Re.Present_Street,
								Re.Present_City,
								Re.Present_State,
								Re.Present_Post_Box,
								Re.Present_Loc,
								Re.Home_Tel_No,
								Re.Mobile_No,
								Re.Permanent_Street,
								Re.Permanent_City,
								Re.Permanent_State,
								Re.Permanentt_Post_Box,
								Re.Initial + ' ' + Re.Emp_First_Name + ' '+ isnull(Re.Emp_Second_Name,'')
								+ ' ' + Re.Emp_Last_Name ,0 from
								inserted as Re inner join T0052_hrms_posted_Recruitment as Pos on
								re.REc_Post_Id = Pos.Rec_Post_ID inner join T0050_HrMS_Recruitment_REquest as Rec on
								pos.rec_req_Id = rec.Rec_Req_Id inner join T0080_Emp_master as Emp on
								Rec.S_Emp_Id = Emp.Emp_Id
			end
		end
	end


