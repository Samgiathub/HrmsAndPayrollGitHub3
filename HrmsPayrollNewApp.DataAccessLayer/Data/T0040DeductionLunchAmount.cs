using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040DeductionLunchAmount
{
    public int TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Designation { get; set; }

    public string? Gender { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EnrollNo { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public decimal? Duration { get; set; }

    public decimal? Amount { get; set; }
}
