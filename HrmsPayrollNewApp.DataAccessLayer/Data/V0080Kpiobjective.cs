using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080Kpiobjective
{
    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? Objective { get; set; }

    public decimal CreatedById { get; set; }

    public string? AddByFlag { get; set; }

    public string? VerificationStatus { get; set; }

    public string? ApproveStatus { get; set; }

    public decimal KpiobjId { get; set; }

    public decimal? EmpKpiId { get; set; }

    public string? Metric { get; set; }

    public decimal KpiAttId { get; set; }
}
