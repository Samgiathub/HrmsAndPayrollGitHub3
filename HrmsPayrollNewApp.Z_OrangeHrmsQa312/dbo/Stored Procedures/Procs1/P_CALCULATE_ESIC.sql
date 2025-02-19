
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_CALCULATE_ESIC]    
    @Approach   TINYINT = 0,
    @AD_ID      NUMERIC = 0,
    @TryCont    INT = 0 OUTPUT
AS
    BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


        IF OBJECT_ID('tempdb..#EMP_ESIC') IS NULL
            BEGIN               
			
                CREATE TABLE #EMP_ESIC
                (
                    Emp_ID      Numeric,
                    AD_ID       Numeric,            
                    AD_Amount   Numeric(18,4),
                    ED_Amount   Numeric(18,4),
                    ED_Percent  Numeric(18,4),
                    Last_Amount Numeric(18,4),
                    AD_Flag     Char(1),
                    Flag_ID     INT,        --10 For ESIC, 20 For Special, 30 For Gross         
                    ROW_ID      INT Identity(1,1),
                    LABEL       VARCHAR(128),
                    IsUpdated   BIT,
					Max_Limit	Numeric(18,4)
                )                               
            END
            
        IF @TryCont IS NULL
            SET @TryCont = 0
        
		
		
        
            
        DECLARE @SPECIAL_FLAG_ID    INT
        DECLARE @GROSS_FLAG_ID      INT
        DECLARE @ESIC_FLAG_ID       INT             
        DECLARE @CTC_FLAG_ID        INT

        DECLARE @ESIC_175_FLAG_ID   INT             
		SET @SPECIAL_FLAG_ID = -1
        
        SELECT  @SPECIAL_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_CALCULATE_ON='Arrears CTC' --SPECIAL
                
        SELECT  @GROSS_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
        WHERE   LABEL='Gross'   --Gross
        
        SELECT  @ESIC_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_DEF_ID=6     --ESIC
        
        SELECT  @CTC_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
        WHERE   LABEL='CTC' --Gross
                
        SELECT  @ESIC_175_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_DEF_ID=3--Employee ESIC  1.75

        
		DECLARE	@EPF_FLAG_ID		INT
		DECLARE	@CPF_FLAG_ID		INT
		DECLARE	@EDLI_FLAG_ID		INT


		SELECT  @EPF_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_DEF_ID=2--Employee PF

		SELECT  @CPF_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_DEF_ID=5--Company ESIC

	SELECT  @EDLI_FLAG_ID = Flag_ID
        FROM    #EMP_ESIC T
                INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
        WHERE   AD_DEF_ID=38--EDLI

        
        UPDATE #EMP_ESIC SET FLAG_ID = 0 WHERE FLAG_ID IS NULL
        
        /*
            0 - Gross Will Be Changed
            1 - 
        */      
        
        DECLARE @ESIC_AD_ID NUMERIC
        SELECT @ESIC_AD_ID = AD_ID FROM #EMP_ESIC WHERE FLAG_ID=@ESIC_FLAG_ID
        

        DECLARE @ESIC_175_AD_ID NUMERIC
        SELECT @ESIC_175_AD_ID = AD_ID FROM #EMP_ESIC WHERE FLAG_ID=@ESIC_175_FLAG_ID
		
		
		--select CTC.AD_AMOUNT,BS.AD_AMOUNT,T.Amount,esic.AD_ID,@SPECIAL_FLAG_ID,@GROSS_FLAG_ID
		--FROM    #EMP_ESIC ESIC
  --                      INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
  --                      INNER JOIN (SELECT  EMP_ID, SUM(T.AD_AMOUNT) AS AMOUNT
  --                                  FROM    #EMP_ESIC T 
  --                                          INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID                                   
  --                                  WHERE   IsNull(AD.AD_PART_OF_CTC,0)=1
  --                                          AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@SPECIAL_FLAG_ID,@GROSS_FLAG_ID) 
  --                                  GROUP BY EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
  --                      INNER JOIN #EMP_ESIC CTC ON CTC.Flag_ID = @CTC_FLAG_ID AND ESIC.Emp_ID=CTC.Emp_ID
		--				INNER JOIN T0050_AD_MASTER AD1 WITH (NOLOCK) ON ESIC.AD_ID=AD1.AD_ID									
  --              WHERE   ESIC.Flag_ID = @SPECIAL_FLAG_ID
  --select @SPECIAL_FLAG_ID,@GROSS_FLAG_ID
  
			   --SELECT  EMP_ID, SUM(T.AD_AMOUNT) AS AMOUNT
      --                              FROM    #EMP_ESIC T 
      --                                      INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID                                   
      --                              WHERE   IsNull(AD.AD_PART_OF_CTC,0)=1
      --                                      AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@SPECIAL_FLAG_ID,@GROSS_FLAG_ID) 
      --                              GROUP BY EMP_ID

				--select CTC.AD_AMOUNT ,  BS.AD_AMOUNT , T.Amount
    --            FROM    #EMP_ESIC ESIC
    --                    INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
    --                    INNER JOIN (SELECT  EMP_ID, SUM(T.AD_AMOUNT) AS AMOUNT
    --                                FROM    #EMP_ESIC T 
    --                                        INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID                                   
    --                                WHERE   IsNull(AD.AD_PART_OF_CTC,0)=1
    --                                        AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@SPECIAL_FLAG_ID,@GROSS_FLAG_ID) 
    --                                GROUP BY EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
    --                    INNER JOIN #EMP_ESIC CTC ON CTC.Flag_ID = @CTC_FLAG_ID AND ESIC.Emp_ID=CTC.Emp_ID
				--		INNER JOIN T0050_AD_MASTER AD1 WITH (NOLOCK) ON ESIC.AD_ID=AD1.AD_ID									
    --            WHERE   ESIC.Flag_ID = 50
	
		
        IF @Approach = 0
            BEGIN         
                /*Calculate Special*/
				
                UPDATE  ESIC
				SET		AD_Amount = ROUND(CTC.AD_AMOUNT -  (BS.AD_AMOUNT + T.Amount), CASE WHEN AD1.Is_Rounding = 1 Then 0 Else 2 End)
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
                        INNER JOIN (SELECT  EMP_ID, SUM(T.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T 
                                            INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID  --and AD_CALCULATE_ON not in ('FIX','FIX + JOINING PRORATE')
                                    WHERE   IsNull(AD.AD_PART_OF_CTC,0)=1
                                            AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@SPECIAL_FLAG_ID,@GROSS_FLAG_ID) 
                                    GROUP BY EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                        INNER JOIN #EMP_ESIC CTC ON CTC.Flag_ID = @CTC_FLAG_ID AND ESIC.Emp_ID=CTC.Emp_ID
						INNER JOIN T0050_AD_MASTER AD1 WITH (NOLOCK) ON ESIC.AD_ID=AD1.AD_ID									
                WHERE   ESIC.Flag_ID = @SPECIAL_FLAG_ID


                /*Calculate Gross*/
                UPDATE  ESIC
                SET     AD_Amount = (B.AD_Amount + Isnull(T.Amount,0))
                FROM    #EMP_ESIC ESIC
                        LEFT OUTER JOIN (SELECT  EMP_ID, Sum(t.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T 
                                            INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
                                    WHERE   --T.Flag_ID NOT IN (@GROSS_FLAG_ID, @CTC_FLAG_ID) 
                                            IsNull(AD.AD_NOT_EFFECT_SALARY,0)=0
                                            AND AD.AD_FLAG = 'I'
                                    GROUP BY EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                        INNER JOIN #EMP_ESIC B ON ESIC.EMP_ID=B.EMP_ID AND B.LABEL='Basic'
                WHERE   ESIC.Flag_ID = @GROSS_FLAG_ID

				
                                               
                /*ESIC 4.75*/

                UPDATE  ESIC
                SET     AD_Amount = CASE WhEN (ISNULL(T.Amount,0) + BS.AD_AMOUNT) >= 21000 AND isnull(ESIC.Calc_ESIC_Forcefully,0) = 0 THEN --Change by dpal 09072024 Isnull
                                        0
                                    ELSE 
                                        Ceiling((ISNULL(T.Amount,0) + BS.AD_AMOUNT) * ESIC.ED_Percent / 100)
                                    END                                 
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
                        LEFT OUTER JOIN (SELECT  T.EMP_ID, Sum(T.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T                                             
                                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                                    WHERE   EAD.EFFECT_AD_ID = @ESIC_AD_ID  
                                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                WHERE   ESIC.Flag_ID = @ESIC_FLAG_ID

            
                /*ESIC 1.75*/
                UPDATE  ESIC
                SET     AD_Amount = CASE WhEN (ISNULL(T.Amount,0) + BS.AD_AMOUNT) >= 21000 AND isnull(ESIC.Calc_ESIC_Forcefully,0) = 0 THEN --Change by dpal 09072024 Added Isnull
                                        0
                                    ELSE 
                                        Ceiling((ISNULL(T.Amount,0) + BS.AD_AMOUNT) * ESIC.ED_Percent / 100)
                                    END
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
                        LEFT OUTER JOIN (SELECT  T.EMP_ID, Sum(T.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T                                             
                                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                                    WHERE   EAD.EFFECT_AD_ID = @ESIC_175_AD_ID 
                                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                WHERE   ESIC.Flag_ID = @ESIC_175_FLAG_ID

				DECLARE @PF_Limit Numeric(18,2)
				DECLARE @Emp_Full_PF BIT
				DECLARE @Cmp_Full_PF BIT
				DECLARE @EPF_AD_ID INT
				DECLARE @CPF_AD_ID INT
								
				
				DECLARE @Cmp_ID iNT

				SELECT @Cmp_ID = Cmp_ID, @Emp_Full_PF = Emp_Full_PF, @Cmp_Full_PF=Cmp_Full_PF FROM #T0095_INCREMENT 

				SELECT	@PF_Limit=PF_LIMIT  --,  
						--@Emp_Full_PF = Case When Full_PF = 1 Then @Emp_Full_PF Else 0 End,		--- Commented by Hardik 18/03/2020 for WCL as circular reference wrong in FNF Case
						--@Cmp_Full_PF = Case When Company_Full_PF = 1 Then @Cmp_Full_PF Else 0 End
				FROM	#T0040_GENERAL_SETTING
				
				
				DECLARE @IncludeOtherAlllowanceInPFCalc BIT
				DECLARE @IncludeOtherAlllowanceInPFCalc_LessBasic BIT
				
				SET @IncludeOtherAlllowanceInPFCalc = 0
				SET @IncludeOtherAlllowanceInPFCalc_LessBasic = 0

				IF EXISTS(select  1 from T0040_SETTING S  WITH (NOLOCK)
							where Setting_Name ='Calculate Full PF, evenif Basic is above PF Limit' And Setting_Value = 1 And Cmp_ID=@Cmp_ID)
					SET @IncludeOtherAlllowanceInPFCalc = 1

				IF EXISTS(select  1 from T0040_SETTING S  WITH (NOLOCK)
							where Setting_Name ='Calculate Full PF, Evenif Basic is Less than PF Limit' And Setting_Value = 1 And Cmp_ID=@Cmp_ID)
					SET @IncludeOtherAlllowanceInPFCalc_LessBasic = 1
            

				/*Employee PF*/
				SELECT @EPF_AD_ID = AD_ID FROM #EMP_ESIC WHERE Flag_ID=@EPF_FLAG_ID
                UPDATE  ESIC
                SET     AD_Amount = ROUND((CASE WhEN BS.ED_Amount < @PF_Limit AND @Emp_Full_PF = 1 THEN  
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit And @IncludeOtherAlllowanceInPFCalc_LessBasic=0 THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END				
											WhEN BS.ED_Amount >= @PF_Limit AND @Emp_Full_PF = 1 THEN  						
												BS.AD_Amount + CASE WHEN @IncludeOtherAlllowanceInPFCalc =1 THEN IsNull(Isnull(T.Amount,0) ,0) Else 0 End
											WHEN @Emp_Full_PF =0 THEN 
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END		
											END * ESIC.ED_Percent / 100),Case When Is_Rounding = 1 Then 0 Else 2 END) ,
						IsUpdated=1
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
						INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.AD_ID=AD.AD_ID
                        Left Outer JOIN (SELECT  T.EMP_ID, Isnull(Sum(T.AD_AMOUNT),0) AS AMOUNT
                                    FROM    #EMP_ESIC T                                             
                                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                                    WHERE   EAD.EFFECT_AD_ID = @EPF_AD_ID
                                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                WHERE   ESIC.Flag_ID = @EPF_FLAG_ID


				/*Company PF*/
				SELECT @CPF_AD_ID = AD_ID FROM #EMP_ESIC WHERE Flag_ID=@CPF_FLAG_ID
                UPDATE  ESIC
                SET     AD_Amount = ROUND((CASE WhEN BS.ED_Amount < @PF_Limit AND @Cmp_Full_PF = 1 THEN  
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit And @IncludeOtherAlllowanceInPFCalc_LessBasic=0 THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END				
											WhEN BS.ED_Amount >= @PF_Limit AND @Cmp_Full_PF = 1 THEN  						
												BS.AD_Amount + CASE WHEN @IncludeOtherAlllowanceInPFCalc =1 THEN IsNull(T.Amount ,0) Else 0 End
											WHEN @Cmp_Full_PF =0 THEN 
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END		
											END * ESIC.ED_Percent / 100),Case When Is_Rounding = 1 Then 0 Else 2 END) ,
						IsUpdated=1
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
						INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.AD_ID=AD.AD_ID
                        Left Outer JOIN (SELECT  T.EMP_ID, Isnull(Sum(T.AD_AMOUNT),0) AS AMOUNT
                                    FROM    #EMP_ESIC T                                             
                                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                                    WHERE   EAD.EFFECT_AD_ID = @CPF_AD_ID
                                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                WHERE   ESIC.Flag_ID = @CPF_FLAG_ID


  			    /*EDLI By Yogesh*/						
				SELECT @EDLI_FLAG_ID = AD_ID FROM #EMP_ESIC WHERE Flag_ID=@EDLI_FLAG_ID
                UPDATE  ESIC
                SET     AD_Amount = ROUND((CASE WhEN BS.ED_Amount < @PF_Limit AND @Cmp_Full_PF = 1 THEN  
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit And @IncludeOtherAlllowanceInPFCalc_LessBasic=0 THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END				
											WhEN BS.ED_Amount >= @PF_Limit AND @Cmp_Full_PF = 1 THEN  						
												BS.AD_Amount + CASE WHEN @IncludeOtherAlllowanceInPFCalc =1 THEN IsNull(T.Amount ,0) Else 0 End
											WHEN @Cmp_Full_PF =0 THEN 
												CASE WHEN (Isnull(T.Amount,0) + BS.AD_Amount) >= @PF_Limit THEN 
													@PF_Limit
												ELSE
													(Isnull(T.Amount,0) + BS.AD_Amount)
												END		
											END  * ESIC.ED_Percent / 100),Case When Is_Rounding = 1 Then 0 Else 2 END) ,
						IsUpdated=1
                FROM    #EMP_ESIC ESIC
                        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
						INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.AD_ID=AD.AD_ID
                        Left Outer JOIN (SELECT  T.EMP_ID, Isnull(Sum(T.AD_AMOUNT),0) AS AMOUNT
                                    FROM    #EMP_ESIC T                                             
                                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                                    WHERE   EAD.EFFECT_AD_ID = @CPF_AD_ID
                                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                WHERE   ESIC.Flag_ID = @EDLI_FLAG_ID


				
                /*Allowance Which are Effect On Basic*/
                DECLARE @EFFECT_AD_ID NUMERIC
                DECLARE @Is_Rounding BIT
                DECLARE curGross CURSOR FAST_FORWARD FOR
					SELECT  DISTINCT ESIC.AD_ID, IS_ROUNDING
					FROM    #EMP_ESIC ESIC
							INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.AD_ID=AD.AD_ID
							INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON ESIC.AD_ID=EAD.EFFECT_AD_ID
					WHERE   AD.AD_CALCULATE_ON = 'Basic Salary' AND FLAG_ID = 0 And ESIC.ED_Percent > 0
                OPEN curGross
                FETCH NEXT FROM curGross INTO @EFFECT_AD_ID, @Is_Rounding
                WHILE @@FETCH_STATUS = 0
                    BEGIN 

						-- Ticket Id 17878 Comment add by Deepal Commented the below query details discusssion by Sandeep QA and after internal discussion commented the below query
                        --UPDATE  ESIC
                        --SET     AD_Amount = CASE WhEN @Is_Rounding = 1 THEN 
                        --                        ROUND((T.Amount + BS.AD_AMOUNT) * ESIC.ED_Percent / 100,0)
                        --                    ELSE 
                        --                        (T.Amount + esic.AD_AMOUNT) * ESIC.ED_Percent / 100
                        --                    END, IsUpdated = 1
                        --FROM    #EMP_ESIC ESIC                              
                        --        INNER JOIN #EMP_ESIC BS ON ESIC.EMP_ID=BS.EMP_ID AND BS.LABEL='BASIC'
                        --        INNER JOIN (SELECT  T.EMP_ID, Sum(T.AD_AMOUNT) AS AMOUNT
                        --                    FROM    #EMP_ESIC T                                             
                        --                            INNER JOIN dbo.T0060_EFFECT_AD_MASTER EAD WITH (NOLOCK) ON T.AD_ID=EAD.AD_ID
                        --                    WHERE   EAD.EFFECT_AD_ID = @EFFECT_AD_ID
                        --                    GROUP BY T.EMP_ID) T ON ESIC.Emp_ID=T.Emp_ID
                        --WHERE   ESIC.AD_ID=@EFFECT_AD_ID
						--ENd Ticket Id 17878 Comment add by Deepal Commented the below query details discusssion by Sandeep QA and after internal discussion commented the below query

				

						IF EXISTS(SELECT 1 FROM #EMP_ESIC WHERE Max_Limit > 0 AND AD_ID=@EFFECT_AD_ID )
							BEGIN
								UPDATE  ESIC
								SET		AD_Amount= Max_Limit
								FROM    #EMP_ESIC ESIC
								WHERE   ESIC.AD_ID=@EFFECT_AD_ID 
										AND AD_Amount > Max_Limit
							END
                        
                        FETCH NEXT FROM curGross INTO @EFFECT_AD_ID, @Is_Rounding
                    END
                CLOSE curGross
                DEALLOCATE curGross
                
                            
                /*Allowance Which are Calculate On Gross*/
                DECLARE @CUR_AD_ID NUMERIC              
                DECLARE curGross CURSOR FAST_FORWARD FOR
                SELECT  ESIC.AD_ID, IS_ROUNDING
                FROM    #EMP_ESIC ESIC
                        INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ESIC.AD_ID=AD.AD_ID                        
                WHERE   AD.AD_CALCULATE_ON = 'Gross Salary' AND FLAG_ID = 0 And ESIC.ED_Percent > 0
                OPEN curGross
                FETCH NEXT FROM curGross INTO @CUR_AD_ID, @Is_Rounding
                WHILE @@FETCH_STATUS = 0
                    BEGIN 
                        UPDATE  ESIC
                        SET     AD_Amount = CASE WhEN @Is_Rounding = 1 THEN 
                                                ROUND(GS.AD_AMOUNT * ESIC.ED_Percent / 100,0)
                                            ELSE 
                                                GS.AD_AMOUNT * ESIC.ED_Percent / 100
                                            END
                        FROM    #EMP_ESIC ESIC                              
								INNER JOIN #EMP_ESIC GS ON ESIC.EMP_ID=GS.EMP_ID AND GS.LABEL='Gross'                               
                        WHERE   ESIC.AD_ID=@CUR_AD_ID

						IF EXISTS(SELECT 1 FROM #EMP_ESIC WHERE Max_Limit > 0 AND AD_ID=@EFFECT_AD_ID )
							BEGIN
								UPDATE  ESIC
								SET		AD_Amount= Max_Limit
								FROM    #EMP_ESIC ESIC
								WHERE   ESIC.AD_ID=@EFFECT_AD_ID 
										AND AD_Amount > Max_Limit
							END
                        
                        FETCH NEXT FROM curGross INTO @CUR_AD_ID, @Is_Rounding
                    END
                CLOSE curGross
                DEALLOCATE curGross
                
                            
                            
                If NOT EXISTS(SELECT 1 FROM #EMP_ESIC WHERE ABS(IsNull(Last_Amount,0) - Ad_Amount) > 0.05) or @TryCont > 10
                    BEGIN						
                        IF @TryCont <> 999	
							BEGIN																							
								EXEC P_CALCULATE_ESIC @Approach = @Approach, @AD_ID=@AD_ID, @TryCont = 999
							END
                        RETURN;
                    END

                /*Updating Current Record for later use*/
                UPDATE  ESIC
                SET     Last_Amount = AD_Amount
                FROM    #EMP_ESIC ESIC

                SET @TryCont = @TryCont + 1


                EXEC P_CALCULATE_ESIC @Approach = @Approach, @AD_ID=@AD_ID, @TryCont = @TryCont Output

                
                                
            END
        ELSE
            BEGIN
                                
                IF OBJECT_ID('tempdb..#FIXED_GROSS') IS NULL
                    BEGIN
                        CREATE TABLE #FIXED_GROSS
                        (
                            Emp_ID          Numeric,
                            TargetCTC       Numeric(18,2),
                            CTC_Without     Numeric(18,2),
                            SP_ESIC         Numeric(18,2),
                            Gross_Without   Numeric(18,2),
                            Gross_ESIC      AS Cast(Gross_Without + SP_ESIC As Numeric(18,2)),
                            ESIC_Rate       Numeric(9,2),
                            ESIC_Ratio      Numeric(9,4),
                            Gross           Numeric(9,2),
                            Special         As Cast(ROUND(Gross - Gross_Without,0) As Numeric(18,0)),
                            ESIC            Numeric(9,2) 
                        )
                        CREATE UNIQUE CLUSTERED INDEX IX_FIXED_GROSS ON #FIXED_GROSS(EMP_ID)
                    END
                
                
                INSERT  INTO #FIXED_GROSS(EMP_ID,ESIC_Rate,ESIC_Ratio)
                SELECT  T.EMP_ID , ED_Percent,Cast((ED_Percent / 100) + 1 As Numeric(9,5))
                FROM    #EMP_ESIC T
                WHERE   AD_ID=@ESIC_AD_ID      
								                                         
            
            
                --Updating TargetCTC
                UPDATE  T
                SET     TargetCTC = CTC.AD_AMOUNT
                FROM    #FIXED_GROSS T                      
                        INNER JOIN #EMP_ESIC CTC ON T.EMP_ID=CTC.EMP_ID AND CTC.LABEL='CTC'
                        
			
                --Updating CTC_Without (CTC Without ESIC & Special Allowance)
                UPDATE  T
                SET     CTC_Without = (T1.AMOUNT + B.AD_AMOUNT)
                FROM    #FIXED_GROSS T
                        INNER JOIN  (SELECT EMP_ID, Sum(t.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T 
                                            INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
                                    WHERE   IsNull(AD.AD_PART_OF_CTC,0)=1
                                            AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@ESIC_FLAG_ID, @SPECIAL_FLAG_ID)                                         
                                    GROUP BY EMP_ID) T1 ON T.Emp_ID=T1.Emp_ID
                        INNER JOIN #EMP_ESIC B ON T.EMP_ID=B.EMP_ID AND B.LABEL='Basic'
                    					

                IF EXISTS(SELECT 1 FROM #FIXED_GROSS t WHERE CTC_Without IS NULL)
                    BEGIN
                        UPDATE  T
                        SET     CTC_Without =  B.AD_AMOUNT, Gross=B.AD_AMOUNT
                        FROM    #FIXED_GROSS T                      
                                INNER JOIN #EMP_ESIC B ON T.EMP_ID=B.EMP_ID AND B.LABEL='Basic'
                                                            
                        
                        UPDATE #FIXED_GROSS
                        SET    ESIC = CEILING((ESIC_Rate * Gross) / 100)
                        --SELECT  * FROM #FIXED_GROSS
                        RETURN
                    END
                                
                
                --Calculate SP_ESIC (Special + ESIC)
                UPDATE  T
                SET     SP_ESIC = TargetCTC - CTC_Without
                FROM    #FIXED_GROSS T
                
                
                --Updating Gross_Without (Gross Without Special Allowance)
                UPDATE  T
                SET     Gross_Without = (T1.AMOUNT + B.AD_AMOUNT)
                FROM    #FIXED_GROSS T
                        INNER JOIN (SELECT  EMP_ID, Sum(t.AD_AMOUNT) AS AMOUNT
                                    FROM    #EMP_ESIC T 
                                            INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON T.AD_ID=AD.AD_ID
                                    WHERE   IsNull(AD.AD_NOT_EFFECT_SALARY,0)=0
                                            AND AD.AD_FLAG = 'I' AND T.FLAG_ID NOT IN (@SPECIAL_FLAG_ID)
                                    GROUP BY EMP_ID) T1 ON T.Emp_ID=T1.Emp_ID
                        INNER JOIN #EMP_ESIC B ON T.EMP_ID=B.EMP_ID AND B.LABEL='Basic'


RECALCULATE:
                        
                --Calculate Gross For Less Than 21000 Limit
                UPDATE  T
                SET     Gross = Gross_ESIC / ESIC_Ratio
                FROM    #FIXED_GROSS T
                --WHERE Gross_ESIC < 21000
				
                
				if EXISTS(SELECT 1 FROM #FIXED_GROSS WHERE Gross > 21000 AND ESIC_Ratio > 1)
					BEGIN
						UPDATE #FIXED_GROSS SET ESIC_Ratio = 1 WHERE Gross > 21000
						GOTO RECALCULATE
					END
                
                
                --Calculate Gross For More Than 21000 Limit
                --UPDATE    T
                --SET       Gross = Gross_ESIC
                --FROM  #FIXED_GROSS T
                --WHERE Gross_ESIC >= 21000
                
                --Calculate ESIC
                UPDATE  T
                SET     ESIC = ROUND(Gross_ESIC - Gross, 0)
                FROM    #FIXED_GROSS T
                --WHERE Gross_ESIC < 21000
                			      
                
                
            END
    END
    



