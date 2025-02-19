


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_PERFORMANCE_DETAIL]
 @PER_DETAIL_ID   NUMERIC(18,0) OUTPUT
,@PER_INC_TRAN_ID NUMERIC(18,0)
,@CMP_ID          NUMERIC(18,0)
,@EMP_ID          NUMERIC(18,0)
,@FOR_DATE        DATETIME
,@PERCENTAGE      NUMERIC(18,2)
,@OUT_OF_PER      NUMERIC(18,2)
,@LOGIN_ID        NUMERIC(18,0)  	
,@TRAN_TYPE       VARCHAR(1)
,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 18102013
,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 18102013

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

								-- Added for audit trail By Ali 18102013 -- Start
									Declare @Old_Emp_Id as numeric
									Declare @Old_Emp_Name as varchar(150)
									Declare @Old_PER_INC_TRAN_ID as numeric
									Declare @Old_Performance_Name as varchar(150)
									Declare @Old_Per as numeric
									Declare @Old_Out_Per as numeric
									Declare @Old_T_Login_Id as numeric
									Declare @Old_T_Login_Name as varchar(150)
									Declare @OldValue as Varchar(Max)
									Declare @Old_FOR_DATE as dateTIME
									Declare @Old_Month as varchar(20)
									Declare @Old_year as varchar(20)
									
									
									Set @Old_Emp_Id  = 0
									Set @Old_Emp_Name  = ''
									Set @Old_PER_INC_TRAN_ID  = 0
									Set @Old_Performance_Name = ''
									Set @Old_Per = 0
									Set @Old_Out_Per  = 0
									Set @Old_T_Login_Id  = 0
									Set @Old_T_Login_Name = ''
									Set @OldValue  = ''
									Set @Old_FOR_DATE = null
									Set @Old_Month = ''
									Set @Old_year = ''
								-- Added for audit trail By Ali 18102013 -- End
IF UPPER(@TRAN_TYPE) = 'I'
	BEGIN
				IF EXISTS(SELECT PER_DETAIL_ID FROM T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND FOR_DATE = @FOR_DATE AND PER_INC_TRAN_ID = @PER_INC_TRAN_ID)
					BEGIN
									-- Added for audit trail By Ali 18102013 -- Start
									Select 
									@Old_Emp_Id = EMP_ID,
									@Old_T_Login_Id =  LOGIN_ID,
									@Old_FOR_DATE = FOR_DATE,
									@Old_Per = PERCENTAGE,
									@Old_Out_Per = OUT_OF_PER,
									@Old_PER_INC_TRAN_ID = PER_INC_TRAN_ID
									From T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK)
									Where EMP_ID=@EMP_ID AND FOR_DATE = @FOR_DATE AND PER_INC_TRAN_ID = @PER_INC_TRAN_ID
								
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
									Set @Old_Performance_Name = (select PER_NAME from T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) where PER_INC_TRAN_ID = @Old_PER_INC_TRAN_ID)
									Set @Old_T_Login_Name = (Select Login_Name from T0011_LOGIN WITH (NOLOCK) where  Login_ID = @Old_T_Login_Id)
									
									set @OldValue = 'old Value' 
													+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Performance : ' + CONVERT(nvarchar(100),ISNULL(@Old_Performance_Name,0))
													+ '#' + 'Points : ' + CONVERT(nvarchar(100),ISNULL(@Old_Per,0))
													+ '#' + 'Total points : ' + CONVERT(nvarchar(100),ISNULL(@Old_Out_Per,0))
													+ '#' + 'Month : ' + CONVERT(nvarchar(100),Month(CONVERT(datetime,@Old_FOR_DATE)))
													+ '#' + 'Year : ' + CONVERT(nvarchar(100),Year(CONVERT(datetime,@Old_FOR_DATE)))
													+ '#' + 'Approved By : ' + ISNULL(@Old_T_Login_Name,'')
																																												
									exec P9999_Audit_Trail @Cmp_ID,'D','Performance Detail',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
									
									-- Added for audit trail By Ali 18102013 -- End
									
									
						delete from T0100_EMP_PERFORMANCE_DETAIL where EMP_ID=@EMP_ID AND FOR_DATE = @FOR_DATE AND PER_INC_TRAN_ID = @PER_INC_TRAN_ID
					END
				SELECT @PER_DETAIL_ID = ISNULL(MAX(PER_DETAIL_ID),0) + 1 FROM T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0100_EMP_PERFORMANCE_DETAIL
					(PER_DETAIL_ID,PER_INC_TRAN_ID,CMP_ID,EMP_ID,FOR_DATE,PERCENTAGE,OUT_OF_PER,LOGIN_ID,SYS_DATE)
				VALUES(@PER_DETAIL_ID,@PER_INC_TRAN_ID,@CMP_ID,@EMP_ID,@FOR_DATE,@PERCENTAGE,@OUT_OF_PER,@LOGIN_ID,GETDATE())	
				
								-- Added for audit trail By Ali 18102013 -- Start
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @EMP_ID)
									Set @Old_Performance_Name = (select PER_NAME from T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) where PER_INC_TRAN_ID = @PER_INC_TRAN_ID)
									Set @Old_T_Login_Name = (Select Login_Name from T0011_LOGIN WITH (NOLOCK) where  Login_ID = @LOGIN_ID)
									
									set @OldValue = 'New Value' 
													+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Performance : ' + CONVERT(nvarchar(100),ISNULL(@Old_Performance_Name,0))
													+ '#' + 'Points : ' + CONVERT(nvarchar(100),ISNULL(@PERCENTAGE,0))
													+ '#' + 'Total points : ' + CONVERT(nvarchar(100),ISNULL(@OUT_OF_PER,0))
													+ '#' + 'Month : ' + CONVERT(nvarchar(100),Month(CONVERT(datetime,@FOR_DATE)))
													+ '#' + 'Year : ' + CONVERT(nvarchar(100),Year(CONVERT(datetime,@FOR_DATE)))
													+ '#' + 'Approved By : ' + ISNULL(@Old_T_Login_Name,'')
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Performance Detail',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
									
								-- Added for audit trail By Ali 18102013 -- End
	END
ELSE IF UPPER(@TRAN_TYPE) = 'D'						
	BEGIN
								-- Added for audit trail By Ali 18102013 -- Start
									Select 
									@Old_Emp_Id = EMP_ID,
									@Old_T_Login_Id =  LOGIN_ID,
									@Old_FOR_DATE = FOR_DATE,
									@Old_Per = PERCENTAGE,
									@Old_Out_Per = OUT_OF_PER,
									@Old_PER_INC_TRAN_ID = PER_INC_TRAN_ID
									From T0100_EMP_PERFORMANCE_DETAIL WITH (NOLOCK)
									Where PER_DETAIL_ID = @PER_DETAIL_ID
								
									Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Old_Emp_Id)
									Set @Old_Performance_Name = (select PER_NAME from T0040_PERFORMANCE_INCENTIVE_MASTER WITH (NOLOCK) where PER_INC_TRAN_ID = @Old_PER_INC_TRAN_ID)
									Set @Old_T_Login_Name = (Select Login_Name from T0011_LOGIN WITH (NOLOCK) where  Login_ID = @Old_T_Login_Id)
									
									set @OldValue = 'old Value' 
													+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Performance : ' + CONVERT(nvarchar(100),ISNULL(@Old_Performance_Name,0))
													+ '#' + 'Points : ' + CONVERT(nvarchar(100),ISNULL(@Old_Per,0))
													+ '#' + 'Total points : ' + CONVERT(nvarchar(100),ISNULL(@Old_Out_Per,0))
													+ '#' + 'Month : ' + CONVERT(nvarchar(100),Month(CONVERT(datetime,@Old_FOR_DATE)))
													+ '#' + 'Year : ' + CONVERT(nvarchar(100),Year(CONVERT(datetime,@Old_FOR_DATE)))
													+ '#' + 'Approved By : ' + ISNULL(@Old_T_Login_Name,'')
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Performance Detail',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
									
								-- Added for audit trail By Ali 18102013 -- End
								
			DELETE FROM T0100_EMP_PERFORMANCE_DETAIL WHERE PER_DETAIL_ID = @PER_DETAIL_ID
	END
			
	

RETURN

