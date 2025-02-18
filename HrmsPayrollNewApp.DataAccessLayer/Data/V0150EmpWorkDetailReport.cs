using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150EmpWorkDetailReport
{
    public string CmpName { get; set; } = null!;

    public string CmpAddress { get; set; } = null!;

    public string CmpPhone { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public DateTime TimeFrom { get; set; }

    public DateTime TimeTo { get; set; }

    public decimal Duration { get; set; }

    public DateTime WorkDate { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string PrjName { get; set; } = null!;

    public string WorkName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal PrjId { get; set; }
}
