using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150EmpLunchInoutRecord
{
    public int IoTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public string? Gender { get; set; }

    public DateTime? ForDate { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? OutTime { get; set; }

    public decimal? Duration { get; set; }
}
