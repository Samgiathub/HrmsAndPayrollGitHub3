CREATE PROCEDURE [dbo].[P0100_Employee_Icard_Detail]
	 @Tran_ID		Numeric output
	,@Cmp_ID		Numeric
	,@Emp_ID		Numeric
	,@For_Date		DateTime	
	,@Comments		varchar(250)
	,@Is_Recovered  tinyint
	,@S_Emp_Id		Numeric
	,@tran_type		varchar(1)
	,@Return_Date   datetime = NULL 
	,@Expiry_Date	datetime = NULL
		
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
		
		IF @Return_Date = '1900-01-01'
			SET @Return_Date = NULL

		IF @Expiry_Date = '1900-01-01'
			SET @Expiry_Date = NULL
		
		DECLARE @Increment_Id as NUMERIC
		DECLARE @Date_Of_Join as DATETIME
		
		select  @Increment_Id = I1.Increment_Id,
				@Date_Of_Join = CASE WHEN ISNULL(@For_Date,EM.Date_Of_Join) <= EM.Date_Of_Join 
									 THEN Em.Date_Of_Join 
									 ELSE ISNULL(@For_Date,EM.Date_Of_Join)
								END
		FROM	T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
				T0095_INCREMENT I1 WITH (NOLOCK) ON I1.Emp_ID = em.Emp_ID INNER JOIN 
				(
					SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
					FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID	
							INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID	
										WHERE I3.Increment_effective_Date <= GETDATE() AND I3.Cmp_ID = @Cmp_Id
										GROUP BY I3.EMP_ID  
										) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
					GROUP BY I2.Emp_ID
				) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID
		WHERE	EM.Emp_ID= @Emp_ID
		
		
		
		if @tran_type ='I' 
			begin
				
				If NOT EXISTS (Select 1 From T0100_ICard_Issue_Detail WITH (NOLOCK) where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID 
								And Effective_Date =  @Date_Of_Join)  
					BEGIN
								select @Tran_ID = Isnull(max(Tran_ID),0) + 1 From T0100_ICard_Issue_Detail WITH (NOLOCK)
								
								
																
								INSERT INTO T0100_ICard_Issue_Detail
								(Tran_ID
								,Cmp_ID
								,Emp_ID
								,Increment_ID
								,Effective_Date
								,Reason
								,Is_Recovered
								,Issue_By
								,Issue_Date   
								,Return_Date
								,[Expiry_date]
								)
								VALUES   
								(@Tran_ID
								,@Cmp_ID
								,@Emp_ID
								,@Increment_Id
								,@Date_Of_Join
								,@Comments
								,@Is_Recovered
								,@S_Emp_Id
								,GETDATE()
								,@Return_Date
								,@Expiry_Date
								)					
						END
				ELSE 
					BEGIN
						 
						 --DELETE FROM T0100_ICard_Issue_Detail WHERE Tran_ID = @Tran_ID					 
						 
						 UPDATE T0100_ICard_Issue_Detail
						 SET	Reason = IsNULL(@Comments,Reason),Is_Recovered = @Is_Recovered
								,Return_Date = @Return_Date
						 where	Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID 
						 		And Effective_Date = @Date_Of_Join				 
						 
						 --select @Tran_ID = Isnull(max(Tran_ID),0) + 1 From T0100_ICard_Issue_Detail
						 
						 --INSERT INTO T0100_ICard_Issue_Detail
							--(Tran_ID
							--,Cmp_ID
							--,Emp_ID
							--,Increment_ID
							--,Effective_Date
							--,Reason
							--,Is_Recovered
							--,Issue_By
							--,Issue_Date   
							
							--)
							--VALUES   
							--(@Tran_ID
							--,@Cmp_ID
							--,@Emp_ID
							--,@Increment_Id
							--,@For_Date
							--,@Comments
							--,@Is_Recovered
							--,@S_Emp_Id
							--,GETDATE()
							--)				
					END
					
					 
			END	
	else if @tran_type ='D'
			begin
				
				DELETE FROM T0100_ICard_Issue_Detail where Tran_ID = @Tran_Id					
							
			--- Added for audit trail By Ali 18102013 -- Start
								--	Select 
								--	@Old_Emp_Id = Emp_ID
								--	,@Old_Adv_Amount = Adv_Amount
								--	,@Old_Comments = Adv_Comments
								--	,@Old_For_Date = For_Date											
								--	From T0100_ADVANCE_PAYMENT
								--	Where Adv_ID = @Adv_ID
									
								--	Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') from T0080_EMP_MASTER Where Emp_ID = @Old_Emp_Id)
								
								--	set @OldValue = 'old Value' 
								--					+ '#' + 'Employee Name : ' + ISNULL(@Old_Emp_Name,'')
								--					+ '#' + 'Effect Date : ' + cast(ISNULL(@Old_For_Date,'') as nvarchar(11))
								--					+ '#' + 'Advance Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Adv_Amount,0))
								--					+ '#' + 'Remarks : ' + ISNULL(@Old_Comments,'')
																																										
								--	exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Admin Advance Approval',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1	
								---- Added for audit trail By Ali 18102013 -- End
							
			end
			
	RETURN




