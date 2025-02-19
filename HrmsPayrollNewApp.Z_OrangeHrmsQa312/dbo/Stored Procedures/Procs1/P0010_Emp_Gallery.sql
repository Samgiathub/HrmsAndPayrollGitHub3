
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0010_Emp_Gallery]
	@Gallery_ID numeric(18,0) output,
	@Type varchar(50),
	@Purpose varchar(150),
	@Name varchar(MAX),
	@Cmp_ID numeric(18,0),
	@Upload_By numeric(18,0),
	@Trans_Type varchar(1),
	@Gallery_Name varchar(500)='',
	@Emp_id_multi varchar(Max)='',
	@Emp_code_Multi varchar(Max)='',
	@User_Id numeric(18,0) = 0,
	@IP_Address varchar(30)= '' ,
    @Expiry_Date Datetime =null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
SET ANSI_WARNINGS OFF;
	
	declare @Path varchar(max)
	declare @OldValue as  varchar(max)
	Declare @String as varchar(max)
	DECLARE @tmp_PATH VARCHAR(MAX)
	DECLARE @NEW_PATH VARCHAR(MAX)

	SET @String=''
	SET @OldValue =''
	
	IF Upper(@Trans_Type) ='I' 
		BEGIN
			SELECT	@Gallery_ID = ISNULL(MAX(Gallery_ID), 0) + 1 
			FROM	T0010_Emp_Gallery WITH (NOLOCK)
	
			IF EXISTS(select 1 from T0010_Emp_Gallery WITH (NOLOCK) where UPPER(Gallery_Name)=UPPER(@Gallery_Name) AND Cmp_ID=@Cmp_ID)
				BEGIN
					SET @Gallery_ID = 0
					RETURN 
				END

			SET	@tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Gallery_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'*','')  
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'`',''),'~',''),'!',''),'@',''),'#',''),'%',''),'%',''),'^',''),'&',''),'*','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'(',''),')',''),'+',''),'=',''),';',''),':','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'?',''),'/',''),'>',''),'<',''),'|',''),'\','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'{',''),'}',''),']',''),'[',''),'"','')				

			SET	@Path = @tmp_PATH + '_' + CAST(@Gallery_ID as varchar(10)) 

			SELECT  @NEW_PATH = COALESCE(@NEW_PATH + '#','') +@path+ '/' +  data 
			FROM	dbo.Split(@Name, '#') T
	
			INSERT INTO T0010_Emp_Gallery(Gallery_ID,Type,Purpose,Name,Cmp_ID,Upload_By,Upload_Date,Gallery_Name,Emp_Id_Multi,Emp_Code_Multi,expiry_date)
				--VALUES(@Gallery_ID,@Type,@Purpose,@Name,@Cmp_ID,@Upload_By,GETDATE(),@Gallery_Name,@Emp_Id_Multi,@Emp_Code_Multi,@Expiry_Date)
			VALUES(@Gallery_ID,@Type,@Purpose,@NEW_PATH,@Cmp_ID,@Upload_By,GETDATE(),@Gallery_Name,@Emp_Id_Multi,@Emp_Code_Multi,@Expiry_Date)
		  
					
			exec P9999_Audit_get @table = 'T0010_Emp_Gallery' ,@key_column='Gallery_Id',@key_Values=@Gallery_ID,@String=@String output
			SET @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	
		END
	ELSE IF upper(@Trans_Type) ='U' 
		BEGIN			
			IF EXISTS(SELECT 1 FROM T0010_Emp_Gallery WITH (NOLOCK) where UPPER(Gallery_Name)=UPPER(@Gallery_Name) and Gallery_ID <> @Gallery_ID and Cmp_ID = @Cmp_ID)
				BEGIN
					SET @Gallery_ID = 0
					RETURN 
				END
							
			EXEC P9999_Audit_get @table='T0010_Emp_Gallery' ,@key_column='Gallery_Id',@key_Values=@Gallery_Id,@String=@String output
			SET @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@Gallery_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'*','')  
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'`',''),'~',''),'!',''),'@',''),'#',''),'%',''),'%',''),'^',''),'&',''),'*','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'(',''),')',''),'+',''),'=',''),';',''),':','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'?',''),'/',''),'>',''),'<',''),'|',''),'\','')
			SET @tmp_PATH = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@tmp_PATH,'{',''),'}',''),']',''),'[',''),'"','')
		
			SET @path = @tmp_PATH +'_' +cast(@Gallery_ID as varchar(max)) 
			
			SELECT	@NEW_PATH = COALESCE(@NEW_PATH + '#','') + @path+ '/' + REPLACE(data ,@path,'')
			FROM	dbo.Split(@Name, '#') T

			SET @NEW_PATH = REPLACE(@NEW_PATH,'//','/')
 
			UPDATE	T0010_Emp_Gallery
			SET		Type = @Type,
					Purpose= @Purpose,	--,Name=@Name -- commented by binal 24122018
					Name=@Name,
					Upload_By = @Upload_By,
					Upload_Date= GETDATE(),--,Gallery_Name= @Gallery_Name -- commented by binal 24122018 
					Emp_Id_Multi=@Emp_id_multi,
					Emp_Code_Multi = @Emp_code_Multi,
					expiry_date = @expiry_date
			FROM	T0010_Emp_Gallery 
			WHERE	Gallery_ID = @Gallery_ID 
		
			exec P9999_Audit_get @table = 'T0010_Emp_Gallery' ,@key_column='Gallery_Id',@key_Values=@Gallery_ID,@String=@String output
			SET @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
	
		
		end
	else if upper(@Trans_Type) ='D'
		begin
			
				exec P9999_Audit_get @table='T0010_Emp_Gallery' ,@key_column='Gallery_Id',@key_Values=@Gallery_Id,@String=@String output
				SET @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
				
			     delete  from T0010_Emp_Gallery where Gallery_ID =@Gallery_ID
					
			end
			exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Gallery Master',@OldValue,@Gallery_ID,@User_Id,@IP_Address
				

	return

