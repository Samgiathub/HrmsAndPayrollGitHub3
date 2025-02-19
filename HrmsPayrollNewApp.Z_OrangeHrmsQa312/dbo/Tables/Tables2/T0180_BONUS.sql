CREATE TABLE [dbo].[T0180_BONUS] (
    [Bonus_ID]                    NUMERIC (18)    NOT NULL,
    [Cmp_ID]                      NUMERIC (18)    NOT NULL,
    [Emp_ID]                      NUMERIC (18)    NOT NULL,
    [From_Date]                   DATETIME        NOT NULL,
    [To_Date]                     DATETIME        NOT NULL,
    [Bonus_Calculated_On]         VARCHAR (20)    NOT NULL,
    [Bonus_Percentage]            NUMERIC (18, 2) NOT NULL,
    [Bonus_Amount]                NUMERIC (18)    NOT NULL,
    [Bonus_Fix_Amount]            NUMERIC (18)    NOT NULL,
    [Bonus_Effect_on_Sal]         NUMERIC (18)    NOT NULL,
    [Bonus_Effect_Month]          NUMERIC (18)    NOT NULL,
    [Bonus_Effect_Year]           NUMERIC (18)    NOT NULL,
    [Bonus_Comments]              VARCHAR (250)   NULL,
    [Bonus_Calculated_Amount]     NUMERIC (18)    CONSTRAINT [DF_T0180_BONUS_Bonus_Calculated_Amount] DEFAULT ((0)) NULL,
    [Is_FNF]                      TINYINT         CONSTRAINT [DF_T0180_BONUS_Is_FNF] DEFAULT ((0)) NULL,
    [Ex_Gratia_Calculated_Amount] NUMERIC (18, 5) CONSTRAINT [DF_T0180_BONUS_Ex_Gratia_Calculated_Amount] DEFAULT ((0)) NULL,
    [Ex_Gratia_Bonus_Amount]      NUMERIC (18, 5) CONSTRAINT [DF_T0180_BONUS_Ex_Gratia_Bonus_Amount] DEFAULT ((0)) NULL,
    [Punja_other_cust_bonus_paid] NUMERIC (18, 2) CONSTRAINT [DF_T0180_BONUS_punja_other_cust_bonus_paid] DEFAULT ((0)) NOT NULL,
    [Intrime_advance_bonus_paid]  NUMERIC (18, 2) CONSTRAINT [DF_T0180_BONUS_Intrime_advance_bonus_paid] DEFAULT ((0)) NOT NULL,
    [Deduction_mis_Amount]        NUMERIC (18, 2) CONSTRAINT [DF_T0180_BONUS_Deduction_mis_Amount] DEFAULT ((0)) NOT NULL,
    [Income_Tax_on_Bonus]         NUMERIC (18, 2) CONSTRAINT [DF_T0180_BONUS_Income_Tax_on_Bonus] DEFAULT ((0)) NOT NULL,
    [Net_Payable_Bonus]           NUMERIC (18, 2) CONSTRAINT [DF_T0180_BONUS_Net_Payble_Bonus] DEFAULT ((0)) NOT NULL,
    [Bonus_Cal_Type]              VARCHAR (50)    NULL,
    CONSTRAINT [PK_T0180_BONUS] PRIMARY KEY CLUSTERED ([Bonus_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0180_BONUS_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0180_BONUS_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO





CREATE TRIGGER [DBO].[Tri_T0190_BONUS_DETAIL]
ON [dbo].[T0180_BONUS]
FOR  INSERT ,update

AS

declare @Cmp_ID as numeric
declare @Emp_Id as numeric
declare	@From_Date	datetime
declare	@To_Date	datetime
declare @Bonus_Tran_ID	numeric(18, 0) 
declare @Bonus_ID	numeric(18, 0)
declare @Bonus_Calculated_Amount	numeric(18, 0)
declare @Bonus_Amount	numeric(18, 0)
declare @tran_type as char
declare @Bonus_Per	numeric(18, 2)
declare @Bonus_Calculated_On	varchar(20)
	begin		

 		Select @cmp_ID = cmp_ID,@emp_id = Emp_ID ,@Bonus_ID = ins.Bonus_ID ,@From_Date = ins.From_Date,@To_Date = ins.To_Date,@Bonus_Per=ins.Bonus_Percentage,@Bonus_Calculated_On=ins.Bonus_Calculated_On
			  From inserted ins	
	
	--Declare @Branch_ID as numeric(18,0)
	--Declare @Bonus_Max_Limit Numeric(18,2)
	
	--declare @Bonus_Calculated_Amount_New	numeric(18, 2)
	--declare @Bonus_Amount_New	numeric(18, 2)
	--declare @From_Date_temp	datetime
	
	--set @From_Date_temp = @From_Date
	--set @Bonus_Calculated_Amount_New = 0
	--set @Bonus_Amount_New = 0
		
	--select @Branch_Id = Branch_Id
	--	FROM T0095_Increment I inner join       
	--	 (SELECT max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
	--	  WHERE  Increment_Effective_date <= @To_Date      
	--	  AND Cmp_ID = @Cmp_ID      
	--	  GROUP BY emp_ID) Qry on      
	--	 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
	--WHERE I.Emp_ID = @Emp_ID
	
	--If @Branch_ID is null   ---Added by hasmukh for check max limit 29 Mar 2012
	--	Begin 
	--		select Top 1 @Bonus_Max_Limit = isnull(Bonus_Max_Limit,0) 
	--		  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
	--		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
	--	End
	--Else
	--	Begin
	--		select @Bonus_Max_Limit = isnull(Bonus_Max_Limit,0) 
	--		  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	--		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	--	End
		
	--	 IF @Bonus_Calculated_On ='Basic'
	--			begin
	--				 While @From_Date <=@To_Date 
	--				 Begin      
						
	--						 select @Bonus_Calculated_Amount = isnull(sum(basic_salary) ,0)
	--							from t0200_MONTHLY_SALARY where cmp_id=@Cmp_ID 
	--								and emp_id=@Emp_ID and month_st_date = @From_Date 
	--						 SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Per )/100)
							
	--						 IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit
	--							set @Bonus_Amount = @Bonus_Max_Limit
							
	--						  select @Bonus_Tran_ID = Isnull(Max(Bonus_Tran_ID),0)  +1 From T0190_BONUS_DETAIL
		  
	--						  insert into t0190_bonus_detail
	--							(Bonus_Tran_ID,Bonus_ID,Cmp_ID,Bonus_Calculated_Amount,Bonus_Amount,Month_Date)
	--							  values
	--							    (@Bonus_Tran_ID,@Bonus_ID,@Cmp_ID,@Bonus_Calculated_Amount,@Bonus_Amount,@From_Date) 	
								    
	--						set @Bonus_Calculated_Amount_New = isnull(@Bonus_Calculated_Amount_New,0) + isnull(@Bonus_Calculated_Amount,0)
	--						set @Bonus_Amount_New = isnull(@Bonus_Amount_New,0) + isnull(@Bonus_Amount,0)
		  	  
	--				 set @From_Date = Dateadd(m,1,@From_Date)      
	--			 End  
				 
	--			 UPDATE T0180_BONUS SET BONUS_AMOUNT = @Bonus_Amount_New 
	--					 , BONUS_CALCULATED_AMOUNT = @Bonus_Calculated_Amount_New 
	--				   WHERE BONUS_ID = @BONUS_ID AND FROM_DATE = @From_Date_temp
		  									   
	--			end
	--		ELSE IF @Bonus_Calculated_On ='Gross'
	--			begin
	--				 While @From_Date <=@To_Date      
	--				 Begin      
		  
	--						select @Bonus_Calculated_Amount = isnull(sum(GROSS_salary) ,0)
	--							from t0200_MONTHLY_SALARY where cmp_id=@Cmp_ID 
	--								and emp_id=@Emp_ID and month_st_date = @From_Date 
	--						SET @Bonus_Amount = ((@Bonus_Calculated_Amount * @Bonus_Per )/100)
							
	--						IF @Bonus_Max_Limit > 0 and @Bonus_Amount > @Bonus_Max_Limit
	--							set @Bonus_Amount = @Bonus_Max_Limit
							
	--						select @Bonus_Tran_ID = Isnull(Max(Bonus_Tran_ID),0) +1 From T0190_BONUS_DETAIL
		  
	--						insert into t0190_bonus_detail
	--						(Bonus_Tran_ID,Bonus_ID,Cmp_ID,Bonus_Calculated_Amount,Bonus_Amount,Month_Date)
	--						values
	--						  (@Bonus_Tran_ID,@Bonus_ID,@Cmp_ID,@Bonus_Calculated_Amount,@Bonus_Amount,@From_Date) 			
		  					
	--	  					set @Bonus_Calculated_Amount_New = isnull(@Bonus_Calculated_Amount_New,0) + isnull(@Bonus_Calculated_Amount,0)
	--						set @Bonus_Amount_New = isnull(@Bonus_Amount_New,0) + isnull(@Bonus_Amount,0)
		  					
		  									   
	--						 set @From_Date = Dateadd(m,1,@From_Date)      
	--				End  
					
	--				UPDATE T0180_BONUS SET BONUS_AMOUNT = @Bonus_Amount_New 
	--						 , BONUS_CALCULATED_AMOUNT = @Bonus_Calculated_Amount_New 
	--					   WHERE BONUS_ID = @BONUS_ID AND FROM_DATE = @From_Date_temp
				end


	

