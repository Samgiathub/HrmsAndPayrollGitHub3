using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150EmpInoutRecord
{
    public DateTime ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? Duration { get; set; }

    public DateTime? AppDate { get; set; }
}
