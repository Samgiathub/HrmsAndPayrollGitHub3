-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_UNIFORM_COST] 
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@Uniform_ID	Numeric
	,@type			Numeric
AS
BEGIN
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @Uni_Apr_Id Numeric(18,0)
	DECLARE @Issue_Date datetime
	DECLARE @Uni_Id Numeric(18,0)
	DECLARE @Uni_Pieces Numeric(18,0)
	DECLARE @Uni_Rate Numeric(18,2)
	DECLARE @Uni_Amount Numeric(18,2)
	DECLARE @Deduct_Pending_Amount Numeric(18,2)
	DECLARE @New_Req_Apr_Id Numeric(18,0)
	DECLARE @TotalPaidAmt Numeric(18,2)
	DECLARE @TotalFabricAmt Numeric(18,2)
	DECLARE @Emp_Full_Name VARCHAR(250)
	DECLARE @Uni_Name VARCHAR(250)
	DECLARE @Uni_Stitching_Price Numeric(18,2)

	IF @Branch_ID = 0  
		SET @Branch_ID = null
	IF @Cat_ID = 0  
		SET @Cat_ID = null

	IF @Grd_ID = 0  
		SET @Grd_ID = null

	IF @Type_ID = 0  
		SET @Type_ID = null

	IF @Dept_ID = 0  
		SET @Dept_ID = null

	IF @Desig_ID = 0  
		SET @Desig_ID = null

	IF @Emp_ID = 0  
		SET @Emp_ID = null
	
	IF @Uniform_ID = 0  
		SET @Uniform_ID = null
		
	DECLARE @Emp_Cons TABLE
		(
			Emp_ID	NUMERIC
		)
	
	DECLARE @Cost_Uniform_Details TABLE
		(			
			Uni_ID Numeric(18,0),
			Uniform_Name varchar(250),
			Emp_ID	NUMERIC(18,0),
			EMP_Full_Name varchar(250),
			Issue_Date DATETIME,
			Purchase_Cost Numeric(18,2),
			Paid_Fabric_Cost Numeric(18,2),
			Unpaid_Fabric_Cost Numeric(18,2),
			Pieces  Numeric(18,0),
			Emp_Code Varchar(250),
			Cmp_Name Varchar(150) NULL,
			Cmp_Address Varchar(500) NULL
		)

	IF @Constraint <> ''
		BEGIN
		
			INSERT INTO @Emp_Cons
			SELECT  cast(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
			INSERT INTO @Emp_Cons

			SELECT I.Emp_Id FROM T0095_Increment I INNER JOIN 
					( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment		
					WHERE Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					GROUP BY emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			WHERE Cmp_ID = @Cmp_ID 
			and ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))
			and Branch_ID = ISNULL(@Branch_ID ,Branch_ID)
			and Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
			and ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))
			and ISNULL(Type_ID,0) = ISNULL(@Type_ID ,ISNULL(Type_ID,0))
			and ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
			and I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN) qry
				WHERE cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		END
				
		Declare @Emp_Code varchar(250)
		DECLARE CurUnifor Cursor For

				SELECT UEI.Uni_Apr_Id,UEI.Emp_ID,UEI.Issue_Date,UEI.Uni_Id,UEI.Uni_Pieces,UEI.Uni_Rate,UEI.Uni_Amount,UEI.Deduct_Pending_Amount,UEI.Uni_Stitching_Price,UEI.New_Req_Apr_Id,UM.Uni_Name,EM.Emp_Full_Name,EM.Alpha_Emp_Code
 				FROM T0100_Uniform_Emp_Issue UEI WITH(NOLOCK)
				INNER JOIN T0040_Uniform_Master UM WITH(NOLOCK) ON UEI.Uni_Id=UM.Uni_ID
				INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON UEI.Emp_ID=EM.Emp_ID
				INNER JOIN @Emp_Cons EC  ON EC.Emp_ID=EM.Emp_ID
				WHERE UEI.Cmp_ID = @Cmp_ID 
				AND (Deduct_Pending_Amount > 0)
				AND Cast(cast(Issue_Date as varchar(11)) as datetime) <= Cast(cast(@To_Date as varchar(11)) as datetime)
				
		OPEN  CurUnifor
			FETCH NEXT FROM CurUnifor INTO @Uni_Apr_Id,@Emp_ID,@Issue_Date,@Uni_Id,@Uni_Pieces,@Uni_Rate,@Uni_Amount,@Deduct_Pending_Amount,@Uni_Stitching_Price,@New_Req_Apr_Id,@Uni_Name,@Emp_Full_Name,@Emp_Code 
				WHILE @@fetch_status = 0
					BEGIN
								DECLARE  @PurchaseCostPerPiece As Decimal(18,2)
								DECLARE  @PurchaseCost As Decimal(18,2)
								DECLARE  @UnPaidFabricCost As Decimal(18,2)

								Print @New_Req_Apr_Id
								print @Emp_Code
								print @Uni_Apr_Id
							
								Set @TotalPaidAmt =(SELECT SUM(UPT.Fabric_Amount)
													FROM	T0140_Uniform_Payment_Transcation UPT WITH(NOLOCK)
															Inner  Join T0100_Uniform_Emp_Issue EMP On Emp.Uni_Apr_Id=UPT.Uni_Apr_Id
															inner JOIN T0100_Uniform_Requisition_Approval URA WITH(NOLOCK) ON EMP.New_Req_Apr_Id=URA.Uni_Apr_Id
													Where UPT.Uni_Apr_Id= @Uni_Apr_Id AND UPT.Emp_ID=@Emp_ID and UPT.Uni_Debit > 0
)
								
								--SET @TotalFabricAmt=@Uni_Amount-(@Uni_Pieces*@Uni_Stitching_Price)


								SET @PurchaseCostPerPiece=(SELECT ISNULL(T.Fabric_Price,0) 
															FROM	T0140_Uniform_Stock_Transaction T WITH (NOLOCK) 
															INNER JOIN (SELECT MAX(For_Date) For_Date,Uni_ID FROM T0140_Uniform_Stock_Transaction WITH (NOLOCK)
																		WHERE(
																			--For_Date <=@To_Date AND  --commneted due to not geetting record 19102020
																			Cmp_ID=@Cmp_ID AND Uni_ID=@Uni_Id AND Stock_Opening >0 AND ISNULL(Fabric_Price,0)<>0 ) GROUP BY Uni_ID)
																		Qry on T.For_Date = Qry.For_Date and T.Uni_ID = Qry.Uni_ID 
															INNER JOIN T0040_Uniform_Master U WITH (NOLOCK) on T.Uni_ID = U.Uni_ID AND T.Cmp_ID = U.Cmp_Id
															WHERE T.Cmp_ID =@Cmp_ID and T.Uni_ID=@Uni_Id)

															print @Uni_Id
								SET @PurchaseCost=(@Uni_Pieces*@PurchaseCostPerPiece)
								IF @PurchaseCost > @TotalPaidAmt
								BEGIN
								SET @UnPaidFabricCost=@PurchaseCost-@TotalPaidAmt
								END
								ELSE
								BEGIN
									IF @TotalPaidAmt > @PurchaseCost
									Begin
										SET @TotalPaidAmt=@PurchaseCost
									END
									SET	@UNPAIDFABRICCOST=0
								END
								INSERT INTO @Cost_Uniform_Details(Uni_ID,Uniform_Name,Emp_ID,EMP_Full_Name,Issue_Date,Purchase_Cost,Paid_Fabric_Cost,Unpaid_Fabric_Cost,Pieces,Emp_Code)
								VALUES(@Uni_Id,@Uni_Name,@Emp_ID,@Emp_Full_Name,@Issue_Date,ISNULL(@PurchaseCost,0),ISNULL(@TotalPaidAmt,0),ISNULL(@UnPaidFabricCost,0),@Uni_Pieces,@Emp_Code)
								
			FETCH NEXT FROM CurUnifor INTO @Uni_Apr_Id,@Emp_ID,@Issue_Date,@Uni_Id,@Uni_Pieces,@Uni_Rate,@Uni_Amount,@Deduct_Pending_Amount,@Uni_Stitching_Price,@New_Req_Apr_Id,@Uni_Name,@Emp_Full_Name,@Emp_Code
				END
		CLOSE CurUnifor
		DEALLOCATE CurUnifor
		
		Declare @Cmp_Name as varchar(150)
		Declare @Cmp_Address As Varchar(500)

		SET @Cmp_Name=(select CM.Cmp_Name from T0010_Company_Master CM WHERE CM.Cmp_Id=@Cmp_ID)
		SET @Cmp_Address=(select CM.Cmp_Address from T0010_Company_Master CM WHERE CM.Cmp_Id=@Cmp_ID)

		Update @Cost_Uniform_Details
		SET Cmp_Name=@Cmp_Name,
			Cmp_Address=@Cmp_Address



		SELECT Emp_Code,EMP_Full_Name As Employee_Name,Uniform_Name,CONVERT ( varchar(12),Issue_Date, 113) as Issue_Date,Pieces,Purchase_Cost As Purchase_Fabric_Cost,Paid_Fabric_Cost As Recovered_Amount,Unpaid_Fabric_Cost As To_Be_Recovered_Amount,Cmp_Name,Cmp_Address FROM @Cost_Uniform_Details 


		
		RETURN
	


END
