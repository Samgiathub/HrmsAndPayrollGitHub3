using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class MyTemp
{
    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? ClaimAprId { get; set; }

    public string? ReimType { get; set; }

    public string? Amount { get; set; }
}
