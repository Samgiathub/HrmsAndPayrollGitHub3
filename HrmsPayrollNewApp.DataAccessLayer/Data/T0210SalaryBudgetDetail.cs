using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210SalaryBudgetDetail
{
    public decimal SalBudgetDetailId { get; set; }

    public decimal? SalBudgetId { get; set; }

    public decimal? SalBudgetTransId { get; set; }

    public decimal? OldBasicSalary { get; set; }

    public decimal? OldGrossSalary { get; set; }

    public decimal? OldCtcSalary { get; set; }

    public decimal? IncrementPer { get; set; }

    public decimal? IncrementBasicAmt { get; set; }

    public decimal? IncrementGrossAmt { get; set; }

    public decimal? IncrementCtcamt { get; set; }

    public decimal? NewBasicSalary { get; set; }

    public decimal? NewGrossSalary { get; set; }

    public decimal? NewCtcSalary { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }
}
