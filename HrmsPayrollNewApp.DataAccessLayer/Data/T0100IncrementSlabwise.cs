using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100IncrementSlabwise
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? GrossSalary { get; set; }

    public decimal? WagesCalculateOn { get; set; }

    public decimal? WagesAmount { get; set; }

    public decimal? WorkingDays { get; set; }

    public decimal? EligibleDay { get; set; }

    public decimal? IncrementAmount { get; set; }

    public decimal? AdditionalIncrement { get; set; }

    public decimal? TotalIncrement { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public DateTime? ForDate { get; set; }
}
