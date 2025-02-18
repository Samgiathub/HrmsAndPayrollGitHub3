using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130EmpWorkplan
{
    public decimal WorkTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public DateTime WorkInTime { get; set; }

    public DateTime WorkOutTime { get; set; }

    public string? WorkPlan { get; set; }

    public string? VisitPlan { get; set; }

    public string? WorkSummary { get; set; }

    public string? VisitSummary { get; set; }
}
