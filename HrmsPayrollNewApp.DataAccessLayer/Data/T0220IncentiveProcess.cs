using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0220IncentiveProcess
{
    public decimal IncTranId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? SchemeId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? IncentiveAmt { get; set; }

    public decimal? AdditionalAmt { get; set; }

    public decimal? DeductionAmt { get; set; }

    public decimal? PaidAmt { get; set; }

    public string? Status { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
